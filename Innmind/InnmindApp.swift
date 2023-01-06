//
//  InnmindApp.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

@main
struct InnmindApp: App {
    let vendor = Vendor.innmind
    let persistence = Persistence.shared
    let packagist = HTTP.Packagist.shared

    var body: some Scene {
        WindowGroup {
            ContentView(vendor: vendor)
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
        .commands {
            InnmindCommands()
        }
    }
}
