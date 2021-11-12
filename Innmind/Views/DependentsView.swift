//
//  DependentsView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct DependentsView: View {
    @EnvironmentObject var svg: Svg

    var package: Package
    
    var body: some View {
        VStack {
            if (svg.loading) {
                HStack() {
                    Image(systemName: "arrow.triangle.2.circlepath.circle")
                    Text("Loading...")
                }
            } else {
                SvgView(content: svg.content!)
            }
        }
            .padding(5)
            .navigationTitle(self.package.name)
    }
}

struct DependentsView_Previews: PreviewProvider {
    static var model = ModelData()

    static var previews: some View {
        DependentsView(package: model.packages[0])
    }
}
