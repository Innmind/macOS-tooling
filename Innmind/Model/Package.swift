//
//  Package.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import Foundation

struct Package: Hashable, Codable, Identifiable {
    var name: String
    var id: Package { self }
}
