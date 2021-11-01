//
//  PackageGraphs.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI
import WebKit

struct PackageGraphs: View {
    @State private var selection: Tab = .dependencies
    
    var package: Package
    
    enum Tab {
        case dependencies
        case dependents
    }
    
    var body: some View {
        TabView(selection: $selection) {
            DependenciesView(package: package)
                .tabItem {
                    Text("Dependencies")
                }
                .tag(Tab.dependencies)
            DependentsView(package: package)
                .tabItem {
                    Text("Dependents")
                }
                .tag(Tab.dependencies)
        }
        .toolbar {
            Button(action: {}) {
                Image(systemName: "arrow.clockwise.circle")
                    .accessibilityLabel("Reload Graph")
            }
        }
    }
}

struct PackageGraphs_Previews: PreviewProvider {
    static var model = ModelData()

    static var previews: some View {
        PackageGraphs(package: model.packages[0])
    }
}
