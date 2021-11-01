//
//  SidebarView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct SidebarView: View {
    let model: ModelData

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
                    ForEach(model.packages, id: \.self) { package in
                        VStack {
                            NavigationLink(
                                destination: PackageGraphs(package: package)
                            ) {
                                PackageRow(package: package)
                            }
                        }
                    }
                }
                    .frame(minWidth: 200)
            }
            .toolbar {
                Button(action: {}) {
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
        SidebarView(model: ModelData())
    }
}
