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
    let packagist: HTTP.Packagist
    nonisolated let name: String

    static let innmind = Vendor(
        Persistence.shared,
        CLI.DependencyGraph.shared,
        HTTP.Packagist.shared,
        "innmind"
    )

    init(
        _ persistence: Persistence,
        _ graph: CLI.DependencyGraph,
        _ packagist: HTTP.Packagist,
        _ name: String
    ) {
        self.persistence = persistence
        self.graph = graph
        self.packagist = packagist
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

    func packages() async -> [StoredPackage] {
        let fetch = StoredPackage.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            let existing = try persistence
                .container
                .viewContext
                .fetch(fetch)

            if !existing.isEmpty {
                return Array<StoredPackage>(existing)
            }
        } catch {
            // let refetch from packagist
        }

        do {
            let packages = try await packagist
                .organization(name)
                .packages
                .sorted(by: { a, b in
                    a.name < b.name
                })
                .map { self.persistPackage($0) }
            persistence.save()

            return packages
        } catch {
            print("Failed to fetch from packagist")

            return []
        }
    }

    func reloadPackages() async -> [StoredPackage] {
        do {
            try persistence
                .container
                .viewContext
                .fetch(StoredPackage.fetchRequest())
                .forEach { persistence.container.viewContext.delete($0) }
        } catch {
            print("failed to delete packages")

            return []
        }

        do {
            let packages = try await packagist
                .organization(name)
                .packages
                .sorted(by: { a, b in
                    a.name < b.name
                })
                .map { self.persistPackage($0) }
            persistence.save()

            return packages
        } catch {
            print("Failed to fetch from packagist")

            return []
        }
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
        nonisolated let packagist: URL
        nonisolated let github: URL?
        nonisolated let actions: URL?
        nonisolated let releases: URL?
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
            packagist = URL(string: "https://packagist.org/packages/\(organization)/\(name)")!
            github = stored.repository
            actions = github?.appendingPathComponent("/actions")
            releases = github?.appendingPathComponent("/releases")
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

        func reloadDependencies() async -> Data? {
            stored.dependencies?.content = nil
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

        func reloadDependents() async -> Data? {
            stored.dependents?.content = nil
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

    private func persistPackage(_ package: Innmind.Packagist.Package) -> StoredPackage {
        let storedPackage = StoredPackage(context: persistence.container.viewContext)
        storedPackage.name = String(package.name.dropFirst(name.count + 1))
        storedPackage.dependencies = StoredSvg(context: persistence.container.viewContext)
        storedPackage.dependents = StoredSvg(context: persistence.container.viewContext)

        return storedPackage
    }
}
