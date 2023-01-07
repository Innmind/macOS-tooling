//
//  ContentView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct ContentView: View {
    let app: Application

    var body: some View {
        WindowView(app: app)
            .frame(minWidth: 600, minHeight: 400)
    }
}

