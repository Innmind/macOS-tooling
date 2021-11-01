//
//  DependenciesView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct DependenciesView: View {
    var package: Package
    
    var body: some View {
        VStack {
            Text("Dependencies")
            Text("innmind/"+self.package.name).font(.title)
            SvgView(content: "</svg>")
            Spacer()
        }
            .padding(5)
            .navigationTitle(self.package.name)
    }
}

struct DependenciesView_Previews: PreviewProvider {
    static var previews: some View {
        DependenciesView(package: packages[0])
    }
}
