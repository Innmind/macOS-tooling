//
//  SidebarView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var model: ModelData

    var packages: [Package] {
        model.packages
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination: VendorView(organization: model.organization)) {
                        HStack() {
                            Text("Organization")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                    }
                    if !model.loading {
                        ForEach(packages) { package in
                            VStack {
                                NavigationLink(
                                    destination: PackageGraphs(package: package)
                                ) {
                                    PackageRow(package: package)
                                }
                            }
                        }
                    } else {
                        HStack() {
                            Image(systemName: "arrow.triangle.2.circlepath.circle")
                            Text("Loading...")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                    }
                }
                    .frame(minWidth: 200)
            }
            .toolbar {
                Button(action: {
                    model.reloadPackages()
                }) {
                    Image(systemName: "arrow.clockwise.circle")
                        .accessibilityLabel("Reload Packages")
                }
            }

            VendorView(organization: model.organization)
        }
    }
}

struct PackageRow: View {
    let package: Package
    
    var body: some View {
        HStack {
            Text(package.name)
            Spacer()
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView().environmentObject(ModelData())
    }
}
