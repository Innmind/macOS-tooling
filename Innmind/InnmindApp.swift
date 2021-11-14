//
//  InnmindApp.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

@main
struct InnmindApp: App {
    let persistence = Persistence.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(ModelData(persistence))
        }
        .commands {
            InnmindCommands()
        }
    }
}
