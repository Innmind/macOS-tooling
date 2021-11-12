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

    var organization: Organization
    var package: Package
    
    enum Tab {
        case dependencies
        case dependents
    }
    
    var body: some View {
        TabView(selection: $selection) {
            DependenciesView(package: package)
                .environmentObject(Svg.dependencies(organization, package))
                .tabItem {
                    Text("Dependencies")
                }
                .tag(Tab.dependencies)
            DependentsView(package: package)
                .environmentObject(Svg.dependents(organization, package))
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
        PackageGraphs(organization: model.organization, package: model.packages[0])
    }
}
