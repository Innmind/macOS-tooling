//
//  PackageGraphs.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI
import WebKit

struct PackageGraphs: View {
    @Environment(\.openURL) private var openURL

    @State private var selection: Tab = .dependencies

    @State private var zoom: Zoom = .max
    @State private var disableModifiers = false
    private var dependencies: Svg
    private var dependents: Svg
    private var organization: String
    private var package: String
    
    enum Tab {
        case dependencies
        case dependents
    }

    init(organization: Organization, package: StoredPackage) {
        dependencies = Svg.dependencies(organization, package)
        dependents = Svg.dependents(organization, package)
        self.organization = organization.name
        self.package = package.name ?? "package-name" // coalesce for the preview
    }
    
    var body: some View {
        VStack {
            switch selection {
            case .dependencies:
                DependenciesView(disableModifiers: $disableModifiers, zoom: $zoom)
                    .environmentObject(dependencies)
            case .dependents:
                DependentsView(disableModifiers: $disableModifiers, zoom: $zoom)
                    .environmentObject(dependents)
            }
        }
        .toolbar {
            Button {
                openURL(URL(string: "https://packagist.org/packages/"+organization+"/"+package)!)
            } label: {
                Text("Packagist")
            }
            Button {
                openURL(URL(string: "https://github.com/"+organization+"/"+package)!)
            } label: {
                Text("Github")
            }
            Button {
                openURL(URL(string: "https://github.com/"+organization+"/"+package+"/actions")!)
            } label: {
                Text("Actions")
            }
            Button {
                openURL(URL(string: "https://github.com/"+organization+"/"+package+"/releases")!)
            } label: {
                Text("Releases")
            }
            HStack {
                Divider()
            }
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
                .disabled(disableModifiers)
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
                .disabled(disableModifiers)
        }
    }
}

struct PackageGraphs_Previews: PreviewProvider {
    static var model = ModelData(Persistence.shared)
    static var package = StoredPackage()

    static var previews: some View {
        PackageGraphs(organization: model.organization, package: package)
    }
}
