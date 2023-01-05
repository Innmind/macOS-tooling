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

    func dependencies(_ package: String) async -> Data? {
        return await graph.of(name, package)
    }

    func dependents(_ package: String) async -> Data? {
        return await graph.dependsOn(name, package)
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
