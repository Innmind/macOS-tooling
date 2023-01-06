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

    let vendor: Vendor

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
                        ForEach(storedPackages) { package in
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
                VendorView(vendor: vendor)
                    .navigationTitle(vendor.name)
            case let .package(package):
                if let name = package.name {
                    PackageGraphs(package: vendor.package(package, name))
                        .navigationTitle(name)
                } else {
                    // when reloading the list of packages we end up with StoredPackage
                    // without a name for some reason so we display the whole vendor as
                    // a default view
                    VendorView(vendor: vendor)
                        .navigationTitle(vendor.name)
                }
            }
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(vendor: .innmind)
            .environmentObject(ModelData.shared)
    }
}
