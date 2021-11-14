//
//  ModelData.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import Foundation
import Combine
import CoreData

final class ModelData: ObservableObject {
    @Published var organization = Organization(displayName: "Innmind", name: "innmind")
    @Published var loading = false

    private var persistence: Persistence
    private var managedObjectContext: NSManagedObjectContext
    private var search: AnyCancellable?

    init(_ persistence: Persistence) {
        self.persistence = persistence
        managedObjectContext = persistence.container.viewContext
    }

    func reloadPackages() {
        do {
            try managedObjectContext
                .fetch(StoredPackage.fetchRequest())
                .forEach { managedObjectContext.delete($0) }
        } catch {
            print("failed to delete packages")

            return
        }

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
                    .map { self.persist($0) }
            }
            .map { packages in
                self.persistence.save()

                return false // means it's done loading
            }
            .replaceError(with: false)
            .receive(on: DispatchQueue.main)
            .assign(to: \.loading, on: self)
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
            .filter { $0.abandoned == PackagistSearch.Abandoned.bool(false) || $0.abandoned == nil }
            .filter { $0.virtual == nil }
            .map { Package(name: String($0.name.dropFirst(self.organization.name.count + 1))) }
    }

    private func persist(_ package: Package) -> Package {
        let storedPackage = StoredPackage(context: managedObjectContext)
        storedPackage.name = package.name

        return package
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
