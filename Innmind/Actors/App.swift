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

    init(
        _ persistence: Persistence,
        _ graph: CLI.DependencyGraph
    ) {
        self.persistence = persistence
        self.graph = graph
    }

    nonisolated
    func vendors() -> [Vendor] {
        return [Vendor.innmind]
    }
}
