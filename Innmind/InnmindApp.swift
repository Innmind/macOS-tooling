//
//  InnmindApp.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

@main
struct InnmindApp: App {
    let app = Application(.shared, .shared, .shared)
    let persistence = Persistence.shared

    var body: some Scene {
        WindowGroup {
            ContentView(app: app)
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
        .commands {
            InnmindCommands()
        }
    }
}
