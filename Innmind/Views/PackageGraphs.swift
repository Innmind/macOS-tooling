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
    @State private var zoom: Zoom = .max
    private var dependencies: Svg
    private var dependents: Svg
    
    enum Tab {
        case dependencies
        case dependents
    }

    init(organization: Organization, package: Package) {
        self.organization = organization
        self.package = package
        dependencies = Svg.dependencies(organization, package)
        dependents = Svg.dependents(organization, package)
    }
    
    var body: some View {
        VStack {
            switch selection {
            case .dependencies:
                DependenciesView(package: package, zoom: $zoom)
                    .environmentObject(dependencies)
            case .dependents:
                DependentsView(package: package, zoom: $zoom)
                    .environmentObject(dependents)
            }
        }
        .toolbar {
            Picker("", selection: $selection) {
                Text("Dependencies").tag(Tab.dependencies)
                Text("Dependents").tag(Tab.dependents)
            }
                .pickerStyle(SegmentedPickerStyle())
            Picker("", selection: $zoom) {
                Text(Zoom.min.name()).tag(Zoom.min)
                Text(Zoom.middle.name()).tag(Zoom.middle)
                Text(Zoom.max.name()).tag(Zoom.max)
            }
                .pickerStyle(SegmentedPickerStyle())
            Button(action: {
                switch selection {
                case .dependencies:
                    dependencies.reload()
                case .dependents:
                    dependents.reload()
                }
            }) {
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
