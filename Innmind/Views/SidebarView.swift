//
//  SidebarView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct SidebarView: View {
    enum Selected: Hashable {
        case organization
        case package(StoredPackage)
    }

    @EnvironmentObject var model: ModelData

    @FetchRequest(
        entity: StoredPackage.entity(),
        sortDescriptors: [NSSortDescriptor(
            keyPath: \StoredPackage.name,
            ascending: true
        )]
    ) var storedPackages: FetchedResults<StoredPackage>

    @State private var selected: Selected = .organization
    private var title: String {
        switch selected {
        case .organization:
            return model.organization.displayName
        case let .package(package):
            return package.name!
        }
    }

    var packages: FetchedResults<StoredPackage> {
        storedPackages
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selected) {
                NavigationLink("Organization", value: Selected.organization)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                Section(
                    header: Text("Packages")
                        .padding(.bottom, 10)
                        .font(.headline)
                ) {
                    if !model.loading {
                        ForEach(packages) { package in
                            NavigationLink(package.name!, value: Selected.package(package))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)

                        }
                    } else {
                        LoadingView()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                }
            }
            .frame(minWidth: 200)
            .toolbar {
                Button(action: {
                    model.reloadPackages()
                }) {
                    Image(systemName: "arrow.clockwise.circle")
                        .accessibilityLabel("Reload Packages")
                }
                    .disabled(model.loading)
            }
        } detail: {
            switch selected {
            case .organization:
                VendorView()
                    .environmentObject(Svg.organization(
                        model.organization,
                        model.findOrganizationSvg()
                    ))
            case let .package(package):
                PackageGraphs(organization: model.organization, package: package)
            }
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView().environmentObject(ModelData(Persistence.shared))
    }
}
