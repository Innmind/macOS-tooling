//
//  ModelData.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import Foundation
import Combine

final class ModelData: ObservableObject {
    @Published var organization = Organization(displayName: "Innmind", name: "innmind")
    @Published var packages: [Package] = [] {
        didSet {
            loading = false
        }
    }
    @Published var loading = false

    private var search: AnyCancellable?

    init() {
        loadPackages()
    }

    func reloadPackages() {
        loadPackages()
    }

    private func loadPackages() {
        loading = true
        self.search(url: "https://packagist.org/search.json?q="+organization.name+"/")
    }

    private func search(url: String) {
        self.search = self.searchPage(url: url)
            .map {
                $0
                    .map { self.parse(result: $0) }
                    .flatMap { $0 }
                    .sorted { a, b in
                        a.name < b.name
                    }
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.packages, on: self)
    }

    private func searchPage(url: String) -> AnyPublisher<[PackagistSearch], Error> {
        let session = URLSession(configuration: .ephemeral)

        return session
            .dataTaskPublisher(for: URL(string: url)!)
            .map { $0.data }
            .decode(type: PackagistSearch.self, decoder: JSONDecoder())
            .map { [$0] }
            .replaceError(with: [])
            .eraseToAnyPublisher()
            .flatMap { results in
                self.attemptNextPage(results: results).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func attemptNextPage(results: [PackagistSearch]) ->AnyPublisher<[PackagistSearch], Error> {
        if let next = results.last?.next {
            return self
                .searchPage(url: next)
                .map { page in
                    var all = results
                    all.append(contentsOf: page)

                    return all
                }
                .eraseToAnyPublisher()
        } else {
            return self.wrapResults(results: results)
        }
    }

    private func wrapResults(results: [PackagistSearch]) -> AnyPublisher<[PackagistSearch], Error> {
        return Just(results)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func parse(result: PackagistSearch) -> [Package] {
        return result.results
            .filter { $0.name.starts(with: self.organization.name) }
            .filter { $0.abandoned == nil }
            .filter { $0.virtual == nil }
            .map { Package(name: String($0.name.dropFirst(self.organization.name.count + 1))) }
    }
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
