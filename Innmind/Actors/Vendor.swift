//
//  Vendor.swift
//  Innmind
//
//  Created by Baptouuuu on 05/01/2023.
//

import Foundation

actor Vendor {
    let persistence: Persistence
    let graph: CLI.DependencyGraph
    let name: String

    static let innmind = Vendor(Persistence.shared, CLI.DependencyGraph.shared, "innmind")

    init(_ persistence: Persistence, _ graph: CLI.DependencyGraph, _ name: String) {
        self.persistence = persistence
        self.graph = graph
        self.name = name
    }

    func svg() async -> Data? {
        let stored = loadSvg()

        if let data = stored.content {
            return data
        }

        return await populate(stored).content
    }

    func reload() async -> Data? {
        let stored = loadSvg()
        stored.content = nil

        return await populate(stored).content
    }

    nonisolated
    func package(_ stored: StoredPackage, _ package: String) -> Package {
        return .init(persistence, graph, stored, name, package)
    }

    actor Package {
        let persistence: Persistence
        let graph: CLI.DependencyGraph
        let organization: String
        nonisolated let name: String
        let stored: StoredPackage

        static let immutable = Vendor.innmind.package(StoredPackage(), "immutable")

        init(
            _ persistence: Persistence,
            _ graph: CLI.DependencyGraph,
            _ stored: StoredPackage,
            _ organization: String,
            _ name: String
        ) {
            self.persistence = persistence
            self.graph = graph
            self.stored = stored
            self.organization = organization
            self.name = name
        }

        func dependencies() async -> Data? {
            if let svg = stored.dependencies?.content {
                return svg
            }

            let svg = await graph.of(organization, name)
            stored.dependencies?.content = svg
            persistence.save()

            return svg
        }

        func dependents() async -> Data? {
            if let svg = stored.dependents?.content {
                return svg
            }

            let svg = await graph.dependsOn(organization, name)
            stored.dependents?.content = svg
            persistence.save()

            return svg
        }
    }

    private func populate(_ stored: StoredSvg) async -> StoredSvg {
        let data = await graph.vendor(name)
        stored.content = data

        persistence.save()

        return stored
    }

    private func loadSvg() -> StoredSvg {
        do {
            let request = StoredSvg.fetchRequest()
            request.predicate = NSPredicate(format: "organization == %@", name)

            let existing = try persistence
                .container
                .viewContext
                .fetch(request)
                .first

            if let existing {
                return existing
            }
        } catch {
            // let the outside scope build the default svg
        }

        let svg = StoredSvg(context: persistence.container.viewContext)
        svg.organization = name

        return svg
    }
}
