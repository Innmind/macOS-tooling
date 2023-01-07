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
    @State private var modify = false
    @State private var newVendor: String = ""

    let app: Application

    var body: some View {
        Button{
            modify = true
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                    .accessibilityLabel("Add Vendor")

                Text("Add Vendor")
            }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
        }
        List(selection: $selected) {
            ForEach(vendors, id: \.self) { vendor in
                NavigationLink(vendor.name, value: vendor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
            }
        }
            .task {
                vendors = await app.vendors()
                if let first = vendors.first {
                    selected = first
                }
            }
            .alert("Add Vendor", isPresented: $modify) {
                TextField("Add Vendor", text: $newVendor)
                    .padding(10)
                    .autocorrectionDisabled()
                Button("OK") {
                    Task {
                        let actors = await app.addVendor(newVendor)
                        DispatchQueue.main.async {
                            vendors = actors
                        }
                    }
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
            .padding(.top, 10)

        List(selection: $selected) {
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
