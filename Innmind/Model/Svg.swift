//
//  Svg.swift
//  Innmind
//
//  Created by Baptouuuu on 12/11/2021.
//

import Foundation

final class Svg: ObservableObject {
    @Published var content: Data?
    private let fetch: () async -> Data?
    private let refetch: () async -> Data?

    private init(
        _ fetch: @escaping () async -> Data?,
        _ refetch: @escaping () async -> Data?
    ) {
        self.fetch = fetch
        self.refetch = refetch
    }

    static func vendor(_ vendor: Vendor) -> Svg {
        return .init(
            {
                return await vendor.svg()
            },
            {
                return await vendor.reload()
            }
        )
    }

    static func dependencies(_ package: Vendor.Package) -> Svg {
        return .init(
            {
                return await package.dependencies()
            },
            {
                return await package.reloadDependencies()
            }
        )
    }

    static func dependents(_ package: Vendor.Package) -> Svg {
        return .init(
            {
                return await package.dependents()
            },
            {
                return await package.reloadDependents()
            }
        )
    }

    func load() {
        run(fetch)
    }

    func reload() {
        content = nil
        run(refetch)
    }

    private func run(_ action: @escaping () async -> Data?) {
        Task {
            let svg = await action()

            DispatchQueue.main.async {
                self.content = svg
            }
        }
    }
}
