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
    private let action: (CLI.DependencyGraph) async -> Data?
    private let entity: StoredSvg?

    private init(
        _ name: String,
        _ action: @escaping (CLI.DependencyGraph) async -> Data?,
        _ entity: StoredSvg? = nil
    ) {
        self.name = name
        self.action = action
        self.entity = entity
        self.content = entity?.content
    }

    static func organization(_ organization: Organization, _ entity: StoredSvg? = nil) -> Svg {
        return .init(
            organization.displayName,
            { dg in
                await dg.vendor(organization.name)
            },
            entity
        )
    }

    static func dependencies(_ organization: Organization, _ package: StoredPackage) -> Svg {
        return .init(
            package.name!,
            { dg in
                await dg.of(organization.name, package.name!)
            },
            package.dependencies
        )
    }

    static func dependents(_ organization: Organization, _ package: StoredPackage) -> Svg {
        return .init(
            package.name!,
            { dg in
                await dg.dependsOn(organization.name, package.name!)
            },
            package.dependents
        )
    }

    func load() {
        fetch(entity)
    }

    func reload() {
        content = nil
        fetch(entity)
    }

    private func fetch(_ entity: StoredSvg?) {
        if (content != nil) {
            return
        }

        Task {
            let run = self.action

            if let svg = await run(CLI.DependencyGraph.shared) {
                DispatchQueue.main.async {
                    self.content = svg
                    entity?.content = svg
                    Persistence.shared.save()
                }
            }
        }
    }
}
