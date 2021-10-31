//
//  PackageGraphs.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct PackageGraphs: View {
    var package: Package
    
    var body: some View {
        VStack {
            Text("innmind/"+self.package.name).font(.title)
            Text("tab group here for each kind of graph")
            Text("graph goes here")
            Spacer()
        }
            .padding(5)
            .navigationTitle(self.package.name)
    }
}

struct PackageGraphs_Previews: PreviewProvider {
    static var previews: some View {
        PackageGraphs(package: packages[0])
    }
}
