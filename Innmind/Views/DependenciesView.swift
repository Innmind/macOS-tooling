//
//  DependenciesView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct DependenciesView: View {
    @EnvironmentObject var svg: Svg

    var package: Package
    @Binding var zoom: Zoom
    
    var body: some View {
        VStack {
            if (svg.loading) {
                HStack() {
                    Image(systemName: "arrow.triangle.2.circlepath.circle")
                    Text("Loading...")
                }
            } else {
                SvgView(content: svg.content!, zoom: $zoom)
            }
        }
            .padding(5)
            .navigationTitle(self.package.name)
    }
}

struct DependenciesView_Previews: PreviewProvider {
    static var model = ModelData()

    static var previews: some View {
        DependenciesView(package: model.packages[0], zoom: .constant(.max))
            .environmentObject(Svg.dependencies(
                Organization(displayName: "Innmind", name: "inn"),
                Package(name: "immutable")
            ))
    }
}
