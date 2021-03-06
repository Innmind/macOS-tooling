//
//  SidebarView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var model: ModelData

    @FetchRequest(
        entity: StoredPackage.entity(),
        sortDescriptors: [NSSortDescriptor(
            keyPath: \StoredPackage.name,
            ascending: true
        )]
    ) var storedPackages: FetchedResults<StoredPackage>

    var packages: FetchedResults<StoredPackage> {
        storedPackages
    }

    var body: some View {
        NavigationView {
            let vendor = VendorView()
                .environmentObject(Svg.organization(
                    model.organization,
                    model.findOrganizationSvg()
                ))

            List {
                NavigationLink(destination: vendor) {
                    HStack() {
                        Text("Organization")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                }
                Section(
                    header: Text("Packages")
                        .padding(.bottom, 10)
                        .font(.headline)
                ) {
                    if !model.loading {
                        ForEach(packages) { package in
                            VStack {
                                NavigationLink(
                                    destination: PackageGraphs(organization: model.organization, package: package)
                                ) {
                                    PackageRow(package: package)
                                }
                            }
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
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                }) {
                    Image(systemName: "sidebar.left")
                        .accessibilityLabel("Toggle Sidebar")
                }
                Button(action: {
                    model.reloadPackages()
                }) {
                    Image(systemName: "arrow.clockwise.circle")
                        .accessibilityLabel("Reload Packages")
                }
                    .disabled(model.loading)
            }

            vendor
        }
    }
}

struct PackageRow: View {
    let package: StoredPackage
    
    var body: some View {
        HStack {
            Text(package.name!)
            Spacer()
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView().environmentObject(ModelData(Persistence.shared))
    }
}
