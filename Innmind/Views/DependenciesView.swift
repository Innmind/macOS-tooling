//
//  DependenciesView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct DependenciesView: View {
    @EnvironmentObject var svg: Svg

    @Binding var disableModifiers: Bool
    @Binding var zoom: Zoom
    
    var body: some View {
        VStack {
            switch self.svg.content {
            case nil:
                LoadingView()
                    .onAppear {
                        disableModifiers = true
                    }
            default:
                SvgView(content: self.svg.content!, zoom: $zoom)
                    .onAppear {
                        disableModifiers = false
                    }
            }
        }
            .navigationTitle(self.svg.name)
            .onAppear {
                self.svg.load()
            }
    }
}

struct DependenciesView_Previews: PreviewProvider {
    static var model = ModelData(Persistence.shared)
    static var package = StoredPackage()

    static var previews: some View {
        DependenciesView(disableModifiers: .constant(true), zoom: .constant(.max))
            .environmentObject(Svg.dependencies(
                Organization(displayName: "Innmind", name: "innmind"),
                package
            ))
    }
}
