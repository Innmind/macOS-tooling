//
//  DependentsView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct DependentsView: View {
    @EnvironmentObject var svg: Svg

    @Binding var zoom: Zoom
    
    var body: some View {
        VStack {
            switch self.svg.content {
            case nil:
                HStack() {
                    Image(systemName: "arrow.triangle.2.circlepath.circle")
                    Text("Loading...")
                }
            default:
                SvgView(content: self.svg.content!, zoom: $zoom)
            }
        }
            .navigationTitle(self.svg.name)
            .onAppear {
                self.svg.load()
            }
    }
}

struct DependentsView_Previews: PreviewProvider {
    static var previews: some View {
        DependentsView(zoom: .constant(.max))
    }
}
