//
//  HTTP.swift
//  Innmind
//
//  Created by Baptouuuu on 06/01/2023.
//

import Foundation

final class HTTP {
    actor Packagist {
        static let shared = Packagist()

        init() {
        }

        func organization(_ name: String) async throws -> Innmind.Packagist.Organization {
            let (data, _) = try await URLSession(configuration: .ephemeral).data(from: URL(string: "https://packagist.org/packages/list.json?vendor="+name+"&fields[]=repository&fields[]=abandoned")!)

            return try JSONDecoder().decode(Innmind.Packagist.Organization.self, from: data)
        }
    }
}
