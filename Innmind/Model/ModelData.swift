//
//  ModelData.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import Foundation
import Combine

final class ModelData: ObservableObject {
    @Published var packages: [Package] = load("packages.json")
    @Published var organization = Organization(displayName: "Innmind", name: "innmind")
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
