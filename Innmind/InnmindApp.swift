//
//  InnmindApp.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

@main
struct InnmindApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            InnmindCommands()
        }
    }
}
