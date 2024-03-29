//
//  App.swift
//  Innmind
//
//  Created by Baptouuuu on 06/01/2023.
//

import Foundation

actor Application {
    let persistence: Persistence
    let graph: CLI.DependencyGraph
    let packagist: HTTP.Packagist
    private var vendorActors: [Vendor] = []

    init(
        _ persistence: Persistence,
        _ graph: CLI.DependencyGraph,
        _ packagist: HTTP.Packagist
    ) {
        self.persistence = persistence
        self.graph = graph
        self.packagist = packagist
    }

    func vendors() -> [Vendor] {
        if !vendorActors.isEmpty {
            return vendorActors
        }

        do {
            vendorActors = try persistence
                .container
                .viewContext
                .fetch(StoredVendor.fetchRequest())
                .sorted(by: { $0.name! < $1.name! })
                .map { Vendor(persistence, graph, packagist, $0) }
        } catch {
            return []
        }

        return vendorActors
    }

    func addVendor(_ name: String) -> [Vendor] {
        if name.isEmpty {
            return vendorActors
        }

        if vendorActors.first(where: { $0.name == name }) != nil {
            return vendorActors
        }

        let stored = StoredVendor(context: persistence.container.viewContext)
        stored.name = name
        stored.svg = StoredSvg(context: persistence.container.viewContext)
        persistence.save()

        vendorActors.append(.init(persistence, graph, packagist, stored))
        vendorActors.sort(by: { $0.name < $1.name })

        return vendorActors
    }

    func deleteVendor(_ vendor: Vendor) async -> [Vendor] {
        await vendor.delete()
        vendorActors.removeAll(where: { $0 == vendor })

        return vendorActors
    }
}
