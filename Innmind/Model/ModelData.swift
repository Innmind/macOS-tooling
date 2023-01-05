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

    let organization = Organization(displayName: "Innmind", name: "innmind")

    private var persistence: Persistence
    private var managedObjectContext: NSManagedObjectContext
    private var search: AnyCancellable?

    init(_ persistence: Persistence) {
        self.persistence = persistence
        managedObjectContext = persistence.container.viewContext
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

        let session = URLSession(configuration: .ephemeral)

        self.search = session
            .dataTaskPublisher(for: URL(string: "https://packagist.org/packages/list.json?vendor="+organization.name+"&fields[]=repository&fields[]=abandoned")!)
            .map { $0.data }
            .decode(type: Packagist.Organization.self, decoder: JSONDecoder())
            .map {
                $0.packages.map { self.persist(organization, $0) }
            }
            .map { packages in
                self.persistence.save()

                return false // means it's done loading
            }
            .eraseToAnyPublisher()
            .replaceError(with: false)
            .receive(on: DispatchQueue.main)
            .assign(to: \.loading, on: self)
    }

    private func persist(_ organization: Organization, _ package: Packagist.Package) -> Packagist.Package {
        let storedPackage = StoredPackage(context: managedObjectContext)
        storedPackage.name = String(package.name.dropFirst(organization.name.count + 1))
        storedPackage.repository = package.repository
        storedPackage.dependencies = StoredSvg(context: managedObjectContext)
        storedPackage.dependents = StoredSvg(context: managedObjectContext)

        return package
    }
}
