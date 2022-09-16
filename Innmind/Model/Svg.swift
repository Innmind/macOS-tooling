//
//  Svg.swift
//  Innmind
//
//  Created by Baptouuuu on 12/11/2021.
//

import Foundation

final class Svg: ObservableObject {
    @Published var content: Data?
    let name: String
    private let action: String
    private let entity: StoredSvg?

    private init(
        _ name: String,
        _ action: String,
        _ entity: StoredSvg? = nil
    ) {
        self.name = name
        self.action = "export PATH=\"/Users/$(whoami)/.composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/opt/homebrew/bin:$PATH\" && dependency-graph \(action)"
        self.entity = entity
        self.content = entity?.content
    }

    static func organization(_ organization: Organization, _ entity: StoredSvg? = nil) -> Svg {
        return .init(organization.displayName, "vendor \(organization.name)", entity)
    }

    static func dependencies(_ organization: Organization, _ dependencies: StoredPackage) -> Svg {
        return .init(dependencies.name!, "of \(organization.name)/\(dependencies.name!)", dependencies.dependencies)
    }

    static func dependents(_ organization: Organization, _ dependents: StoredPackage) -> Svg {
        return .init(dependents.name!, "depends-on \(organization.name)/\(dependents.name!) \(organization.name)", dependents.dependents)
    }

    func load() {
        fetch(action, entity)
    }

    func reload() {
        content = nil
        fetch(action, entity)
    }

    private func fetch(_ action: String, _ entity: StoredSvg?) {
        if (content != nil) {
            return
        }

        Shell.run(self.action, callback: { [self] tmpDirectory, data in
            let file = String(decoding: data, as: UTF8.self).trimmingCharacters(in: ["\n"])

            do {
                let svg = try Data(contentsOf: URL(fileURLWithPath: tmpDirectory.appending(file)))

                DispatchQueue.main.async {
                    self.content = svg
                    entity?.content = svg
                    Persistence.shared.save()
                }
            } catch {
                return
            }
        })
    }
}
