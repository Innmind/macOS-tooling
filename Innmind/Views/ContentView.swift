//
//  ContentView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: ModelData

    var body: some View {
        SidebarView()
            .environmentObject(model)
            .frame(minWidth: 600, minHeight: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData(Persistence.shared))
    }
}
