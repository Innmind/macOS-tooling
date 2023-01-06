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
    private let dependencies: Svg
    private let dependents: Svg
    private let package: Vendor.Package
    
    enum Tab {
        case dependencies
        case dependents
    }

    init(package: Vendor.Package) {
        self.package = package
        dependencies = Svg.dependencies(package)
        dependents = Svg.dependents(package)
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
                openURL(package.packagist)
            } label: {
                Text("Packagist")
            }
            if let github = package.github {
                Button {
                    openURL(github)
                } label: {
                    Text("Github")
                }
            }
            if let actions = package.actions {
                Button {
                    openURL(actions)
                } label: {
                    Text("Actions")
                }
            }
            if let releases = package.releases {
                Button {
                    openURL(releases)
                } label: {
                    Text("Releases")
                }
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
        PackageGraphs(package: .immutable)
    }
}
