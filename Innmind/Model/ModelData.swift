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

    func reloadPackages() {
        // todo load from packagist
        packages = []
        loadPackages()
    }

    private func loadPackages() {
        let results: [PackagistSearch] = []
        self.search(url: "https://packagist.org/search.json?q="+organization.name+"/", searches: results)
    }

    private func search(url: String, searches: [PackagistSearch]) {
        let task = URLSession.shared.dataTask(with: URL(string: url)!) {(data, response, error) in
            guard let data = data else { return }
            var results = searches
            let decoder = JSONDecoder()

            do {
                let result = try decoder.decode(PackagistSearch.self, from: data)
                results.append(result)

                if (result.next != nil) {
                    self.search(url: result.next!, searches: results)
                } else {
                    self.putPackages(results: results)
                }
            } catch {
                return
            }
        }

        task.resume()
    }

    private func putPackages(results: [PackagistSearch]) {
        var packages: [PackagistSearch.Result] = []
        results.forEach {
            packages.append(contentsOf: $0.results)
        }
        self.packages = packages
            .filter { $0.abandoned == nil }
            .map { Package(name: String($0.name.dropFirst(organization.name.count + 1))) }
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
