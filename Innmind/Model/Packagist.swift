//
//  Packagist.swift
//  Innmind
//
//  Created by Baptouuuu on 05/01/2023.
//

import Foundation

struct Packagist {
    struct Package: Hashable, Decodable, Identifiable {
        let name: String
        let repository: URL?
        var id: Package { self }
    }

    struct Vendor: Hashable, Decodable {
        let packages: [Packagist.Package]

        private enum CodingKeys: String, CodingKey {
            case packages
        }
        private struct Package: Hashable, Codable {
            private enum Repository: Hashable, Codable {
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

                func url() -> URL? {
                    switch self {
                    case .none:
                        return nil
                    case let .github(url):
                        return url
                    }
                }
            }

            private enum Abandoned: Hashable, Codable {
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

            private let repository: Repository
            private let abandoned: Abandoned

            func stillActive() -> Bool {
                switch abandoned {
                case let .bool(bool):
                    return !bool
                }
            }

            func url() -> URL? {
                return repository.url()
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let packages = try container.decode([String:Package].self, forKey: .packages)
            var concrete: [Packagist.Package] = []

            for (name, package) in packages {
                if package.stillActive() {
                    concrete.append(Packagist.Package(
                        name: name,
                        repository: package.url()
                    ))
                }
            }
            self.packages = concrete
        }
    }
}
