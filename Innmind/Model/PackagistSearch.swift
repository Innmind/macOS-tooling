//
//  PackagistSearch.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import Foundation

struct PackagistSearch: Hashable, Codable {
    let results: [Result]
    let next: String?

    enum Abandoned: Hashable, Codable {
        case bool (Bool)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let _ = try? container.decode(String.self) {
                self = .bool(true)
                return
            }

            if let bool = try? container.decode(Bool.self) {
                self = .bool(bool)
                return
            }

            throw DecodingError.typeMismatch(
                Abandoned.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Abandoned should be a string or a bool")
            )
        }
    }

    enum Repository: Hashable, Codable {
        case github (URL)
        case none

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let url = try? container.decode(String.self) {
                if url.isEmpty {
                    self = .none
                    return
                }

                if let github = URL(string: url.trimmingCharacters(in: ["/"])) {
                    self = .github(github)
                    return
                }
            }

            self = .none
        }
    }

    struct Result: Hashable, Codable {
        let name: String
        let repository: Repository
        let abandoned: Abandoned?
        let virtual: Bool?

        func repositoryUrl() -> URL? {
            switch repository {
            case let .github(url):
                return url
            case .none:
                return nil
            }
        }
    }
}
