//
//  Svg.swift
//  Innmind
//
//  Created by Baptouuuu on 12/11/2021.
//

import Foundation

final class Svg: ObservableObject {
    @Published var content: Data?
    private let action: String

    private init(_ action: String) {
        self.action = "export PATH=\"/Users/$(whoami)/.composer/vendor/bin:/usr/local/sbin:/usr/local/bin:$PATH\" && dependency-graph \(action)"
        load(action)
    }

    static func organization(_ organization: Organization) -> Svg {
        return .init("vendor \(organization.name)")
    }

    static func dependencies(_ organization: Organization, _ dependencies: Package) -> Svg {
        return .init("of \(organization.name)/\(dependencies.name)")
    }

    static func dependents(_ organization: Organization, _ dependents: Package) -> Svg {
        return .init("depends-on \(organization.name)/\(dependents.name) \(organization.name)")
    }

    func reload() {
        content = nil
        load(action)
    }

    private func load(_ action: String) {
        Shell.run(self.action, callback: { [self] svg in
            DispatchQueue.main.async {
                self.content = svg
            }
        })
    }
}
