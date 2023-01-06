//
//  ModelData.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import Foundation
import Combine
import CoreData

final class ModelData: ObservableObject {
    @Published var loading = false

    static let shared = ModelData(Persistence.shared, HTTP.Packagist.shared)

    let organization = Organization(displayName: "Innmind", name: "innmind")

    private var persistence: Persistence
    private var managedObjectContext: NSManagedObjectContext
    private var packagist: HTTP.Packagist

    init(_ persistence: Persistence, _ packagist: HTTP.Packagist) {
        self.persistence = persistence
        managedObjectContext = persistence.container.viewContext
        self.packagist = packagist
    }

    func reloadPackages() {
        do {
            try managedObjectContext
                .fetch(StoredPackage.fetchRequest())
                .forEach { managedObjectContext.delete($0) }
        } catch {
            print("failed to delete packages")

            return
        }

        load(organization)
    }

    func findOrganizationSvg() -> StoredSvg {
        do {
            let request = StoredSvg.fetchRequest()
            request.predicate = NSPredicate(format: "organization != nil")
            let existing = try managedObjectContext
                .fetch(request)
                .first

            if (existing != nil) {
                return existing!
            }
        } catch {
            // let the outside scope build the default svg
        }

        let svg = StoredSvg(context: managedObjectContext)
        svg.organization = organization.name
        persistence.save()

        return svg
    }

    private func load(_ organization: Organization) {
        loading = true

        Task {
            let parsed = try await packagist.organization(organization.name)
            parsed.packages.forEach {
                self.persist(organization, $0)
            }
            self.persistence.save()

            DispatchQueue.main.async {
                self.loading = false
            }
        }
    }

    private func persist(_ organization: Organization, _ package: Packagist.Package) {
        let storedPackage = StoredPackage(context: managedObjectContext)
        storedPackage.name = String(package.name.dropFirst(organization.name.count + 1))
        storedPackage.repository = package.repository
        storedPackage.dependencies = StoredSvg(context: managedObjectContext)
        storedPackage.dependents = StoredSvg(context: managedObjectContext)
    }
}
