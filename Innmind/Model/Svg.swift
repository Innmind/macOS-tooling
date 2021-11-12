//
//  Svg.swift
//  Innmind
//
//  Created by Baptouuuu on 12/11/2021.
//

import Foundation

final class Svg: ObservableObject {
    @Published var content: String? {
        didSet {
            loading = false
        }
    }
    @Published var loading = true

    private init() {
        Shell.run("export PATH=\"/Users/$(whoami)/.composer/vendor/bin:/usr/local/sbin:/usr/local/bin:$PATH\" && cat $(dependency-graph of innmind/immutable)", callback: { [self] svg in
            DispatchQueue.main.async {
                self.content = svg
            }
        })
    }

    static func organization(_ organization: Organization) -> Svg {
        return .init()
    }

    static func dependencies(_ dependencies: Package) -> Svg {
        return .init()
    }

    static func dependents(_ dependencies: Package) -> Svg {
        return .init()
    }
}
