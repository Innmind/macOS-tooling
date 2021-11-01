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
    @Published var packages: [Package] = load("packages.json")

    private var search: AnyCancellable?

    func reloadPackages() {
        // todo load from packagist
        packages = []
        loadPackages()
    }

    private func loadPackages() {
        self.search(url: "https://packagist.org/search.json?q="+organization.name+"/")
    }

    private func search(url: String) {
        self.search = URLSession
            .shared
            .dataTaskPublisher(for: URL(string: url)!)
            .map { $0.data }
            .decode(type: PackagistSearch.self, decoder: JSONDecoder())
            .map { self.parse(result: $0) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: \.packages, on: self)
    }

    private func parse(result: PackagistSearch) -> [Package] {
        return result.results
            .filter { $0.name.starts(with: self.organization.name) }
            .filter { $0.abandoned == nil }
            .filter { $0.virtual == nil }
            .map { Package(name: String($0.name.dropFirst(self.organization.name.count + 1))) }
            .sorted { a, b in
                a.name < b.name
            }
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
