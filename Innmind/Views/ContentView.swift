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
        SidebarView(app)
            .frame(minWidth: 600, minHeight: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(app: .init(.shared, .shared))
    }
}
