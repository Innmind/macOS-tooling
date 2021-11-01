//
//  PackagistSearch.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import Foundation

struct PackagistSearch: Hashable, Codable {
    let results: [Result]
    let total: Int
    let next: String?

    struct Result: Hashable, Codable {
        let name: String
        let abandoned: String?
    }
}
