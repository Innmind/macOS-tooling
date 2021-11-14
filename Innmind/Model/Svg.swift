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
        self.action = "export PATH=\"/Users/$(whoami)/.composer/vendor/bin:/usr/local/sbin:/usr/local/bin:$PATH\" && dependency-graph \(action)"
        self.entity = entity
        self.content = entity?.content // if it's not empty then load() won't do anything
        load(self.action, self.entity)
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

    func reload() {
        content = nil
        load(action, entity)
    }

    private func load(_ action: String, _ entity: StoredSvg?) {
        if (content != nil) {
            return
        }

        Shell.run(self.action, callback: { [self] svg in
            DispatchQueue.main.async {
                self.content = svg
                entity?.content = svg
                Persistence.shared.save()
            }
        })
    }
}
