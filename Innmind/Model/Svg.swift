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

    init(with organization: Organization) {
        Shell.run("export PATH=\"/Users/$(whoami)/.composer/vendor/bin:/usr/local/sbin:/usr/local/bin:$PATH\" && cat $(dependency-graph of innmind/immutable)", callback: { [self] svg in
            DispatchQueue.main.async {
                self.content = svg
            }
        })
    }
}
