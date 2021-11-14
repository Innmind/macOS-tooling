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
    @Binding var zoom: Zoom
    
    var body: some View {
        VStack {
            switch svg.content {
            case nil:
                HStack() {
                    Image(systemName: "arrow.triangle.2.circlepath.circle")
                    Text("Loading...")
                }
            default:
                SvgView(content: svg.content!, zoom: $zoom)
            }
        }
            .padding(5)
            .navigationTitle(self.package.name)
    }
}

struct DependentsView_Previews: PreviewProvider {
    static var model = ModelData(Persistence.shared)

    static var previews: some View {
        DependentsView(package: .init(name: "immutable"), zoom: .constant(.max))
    }
}
