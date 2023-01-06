//
//  Svg.swift
//  Innmind
//
//  Created by Baptouuuu on 12/11/2021.
//

import Foundation

final class Svg: ObservableObject {
    @Published var content: Data?
    private let action: () async -> Data?

    private init(_ action: @escaping () async -> Data?) {
        self.action = action
    }

    static func dependencies(_ package: Vendor.Package) -> Svg {
        return .init(
            {
                return await package.dependencies()
            }
        )
    }

    static func dependents(_ package: Vendor.Package) -> Svg {
        return .init(
            {
                return await package.dependents()
            }
        )
    }

    func load() {
        fetch()
    }

    func reload() {
        content = nil
        fetch()
    }

    private func fetch() {
        if (content != nil) {
            return
        }

        Task {
            let run = self.action
            let svg = await run()

            DispatchQueue.main.async {
                self.content = svg
            }
        }
    }
}
