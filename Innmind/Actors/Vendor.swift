//
//  Vendor.swift
//  Innmind
//
//  Created by Baptouuuu on 05/01/2023.
//

import Foundation

actor Vendor: Hashable {
    let persistence: Persistence
    let graph: CLI.DependencyGraph
    let packagist: HTTP.Packagist
    nonisolated let name: String
    var packages: [Package] = []

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

    static func == (lhs: Vendor, rhs: Vendor) -> Bool {
        return lhs.name == rhs.name
    }

    nonisolated
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
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

    func packages() async -> [Package] {
        if (!packages.isEmpty) {
            return packages
        }

        let fetch = StoredPackage.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            let existing = try persistence
                .container
                .viewContext
                .fetch(fetch)

            if !existing.isEmpty {
                packages = Array<StoredPackage>(existing).map { package($0) }

                return packages
            }
        } catch {
            // let refetch from packagist
        }

        do {
            packages = try await packagist
                .organization(name)
                .packages
                .sorted(by: { a, b in
                    a.name < b.name
                })
                .map { self.persistPackage($0) }
                .map { package($0) }
            persistence.save()

            return packages
        } catch {
            print("Failed to fetch from packagist")

            return []
        }
    }

    func reloadPackages() async -> [Package] {
        packages.forEach { $0.delete() }
        packages = []
        persistence.save()

        do {
            packages = try await packagist
                .organization(name)
                .packages
                .sorted(by: { a, b in
                    a.name < b.name
                })
                .map { self.persistPackage($0) }
                .map { package($0) }
            persistence.save()

            return packages
        } catch {
            print("Failed to fetch from packagist")

            return []
        }
    }

    actor Package: Hashable {
        let persistence: Persistence
        let graph: CLI.DependencyGraph
        nonisolated let organization: String
        nonisolated let name: String
        nonisolated let packagist: URL
        nonisolated let github: URL?
        nonisolated let actions: URL?
        nonisolated let releases: URL?
        let stored: StoredPackage

        private static var storedImmutable: StoredPackage {
            let package = StoredPackage()
            package.name = "immutable"

            return package
        }
        static let immutable = Vendor.innmind.package(Package.storedImmutable)

        init(
            _ persistence: Persistence,
            _ graph: CLI.DependencyGraph,
            _ stored: StoredPackage,
            _ organization: String
        ) {
            self.persistence = persistence
            self.graph = graph
            self.stored = stored
            self.organization = organization
            self.name = stored.name!
            packagist = URL(string: "https://packagist.org/packages/\(organization)/\(name)")!
            github = stored.repository
            actions = github?.appendingPathComponent("/actions")
            releases = github?.appendingPathComponent("/releases")
        }

        static func == (lhs: Package, rhs: Package) -> Bool {
            return lhs.organization == rhs.organization && lhs.name == rhs.name
        }

        nonisolated
        func hash(into hasher: inout Hasher) {
            hasher.combine(organization)
            hasher.combine(name)
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

        // use this method only from the vendor managing this actor
        nonisolated
        func delete() {
            persistence.container.viewContext.delete(stored.dependents!)
            persistence.container.viewContext.delete(stored.dependencies!)
            persistence.container.viewContext.delete(stored)
        }
    }

    nonisolated
    private func package(_ stored: StoredPackage) -> Package {
        return .init(persistence, graph, stored, name)
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
        storedPackage.repository = package.repository
        storedPackage.dependencies = StoredSvg(context: persistence.container.viewContext)
        storedPackage.dependents = StoredSvg(context: persistence.container.viewContext)

        return storedPackage
    }
}
