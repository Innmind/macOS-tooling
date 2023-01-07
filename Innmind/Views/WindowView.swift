//
//  WindowView.swift
//  Innmind
//
//  Created by Baptouuuu on 06/01/2023.
//

import SwiftUI

struct WindowView: View {
    @State private var selectedVendor: Vendor? = nil
    @State private var selectedPackage: Vendor.Package? = nil

    let app: Application

    private var title: String {
        if let selectedPackage {
            return selectedPackage.name
        }

        if let selectedVendor {
            return selectedVendor.name
        }

        return "Select a vendor"
    }

    var body: some View {
        NavigationSplitView {
            VendorsView(selected: $selectedVendor, app: app)
        } content: {
            if let vendor = selectedVendor {
                PackagesView(selected: $selectedPackage, vendor: vendor)
            } else {
                Text("Select a vendor")
            }
        } detail: {
            DisplayTargetSvgView(vendor: $selectedVendor, package: $selectedPackage)
        }
            .navigationTitle(title)
    }
}

struct VendorsView: View {
    @Binding var selected: Vendor?
    @State private var vendors: [Vendor] = []

    let app: Application

    var body: some View {
        List(selection: $selected) {
            ForEach(vendors, id: \.self) { vendor in
                NavigationLink(vendor.name, value: vendor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
            }
        }
            .task {
                vendors = app.vendors()
                if let first = vendors.first {
                    selected = first
                }
            }
    }
}

struct PackagesView: View {
    @Binding var selected: Vendor.Package?

    let vendor: Vendor

    @State private var packages: [Vendor.Package] = []
    @State private var loading = false

    var body: some View {
        List(selection: $selected) {
            Button(action: {
                loading = true
                selected = nil
                packages = []
                Task {
                    let fetched = await vendor.reloadPackages()
                    DispatchQueue.main.async {
                        packages = fetched
                        loading = false
                    }
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise.circle")
                        .accessibilityLabel("Reload Packages")

                    Text("Reload packages")
                }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
                .disabled(loading)

            if !loading {
                ForEach(packages, id: \.self) { package in
                    NavigationLink(package.name, value: package)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
            } else {
                LoadingView()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
            }
        }
            .task {
                loading = true
                packages = await vendor.packages()
                loading = false
            }
    }
}

struct DisplayTargetSvgView: View {
    @Binding var vendor: Vendor?
    @Binding var package: Vendor.Package?

    var body: some View {
        if let package {
            PackageGraphs(package: package)
        } else if let vendor {
            VendorView(vendor: vendor)
        } else {
            EmptyView()
        }
    }
}

struct WindowView_Previews: PreviewProvider {
    static var previews: some View {
        WindowView(app: .init(.shared, .shared))
    }
}
