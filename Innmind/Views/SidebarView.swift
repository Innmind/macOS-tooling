//
//  SidebarView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct SidebarView: View {
    let packages: [Package]

    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination: VendorView()) {
                        HStack() {
                            Text("Organization")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                    }
                    ForEach(packages, id: \.self) { package in
                        VStack {
                            NavigationLink(
                                destination: PackageGraphs(package: package)
                            ) {
                                PackageRow(package: package)
                            }
                        }
                    }
                }
                    .frame(minWidth: 100)
            }

            VendorView()
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
        SidebarView(packages: packages)
    }
}
