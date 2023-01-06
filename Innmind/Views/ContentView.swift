//
//  ContentView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: ModelData

    let vendor: Vendor

    var body: some View {
        SidebarView(vendor: vendor)
            .environmentObject(model)
            .frame(minWidth: 600, minHeight: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(vendor: .innmind)
            .environmentObject(ModelData.shared)
    }
}
