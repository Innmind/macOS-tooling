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
            VendorsView(selectedVendor: $selectedVendor, selectedPackage: $selectedPackage, app: app)
                .frame(minWidth: 200)
        } content: {
            if let vendor = selectedVendor {
                PackagesView(selected: $selectedPackage, vendor: vendor).id(vendor.name)
            } else {
                Text("Select a vendor")
            }
        } detail: {
            DisplayTargetSvgView(vendor: $selectedVendor, package: $selectedPackage).id(selectedVendor?.name)
        }
            .navigationTitle(title)
    }
}

struct VendorsView: View {
    @Binding var selectedVendor: Vendor?
    @Binding var selectedPackage: Vendor.Package?
    @State private var vendors: [Vendor] = []
    @State private var new = false
    @State private var newVendor: String = ""
    @State private var edit = false

    let app: Application

    var body: some View {
        HStack {
            Button{
                edit.toggle()
            } label: {
                Text("Edit")
                    .accessibilityLabel("Edit Vendors")
            }
                .buttonStyle(.link)
            Spacer()
            Button{
                new = true
            } label: {
                Image(systemName: "plus.circle")
                    .accessibilityLabel("Add Vendor")
            }
                .buttonStyle(.link)
        }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        List(selection: $selectedVendor) {
            ForEach(vendors, id: \.self) { vendor in
                HStack {
                    if edit {
                        Button {
                            Task {
                                if selectedVendor == vendor {
                                    selectedPackage = nil
                                    selectedVendor = nil
                                }

                                let actors = await app.deleteVendor(vendor)
                                DispatchQueue.main.async {
                                    vendors = actors
                                    edit = !actors.isEmpty
                                }
                            }
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                            .buttonStyle(.plain)
                    }
                    NavigationLink(vendor.name, value: vendor)
                }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
            }
        }
            .task {
                vendors = await app.vendors()
                if let first = vendors.first {
                    selectedVendor = first
                }
            }
            .alert("Add Vendor", isPresented: $new) {
                TextField("Add Vendor", text: $newVendor)
                    .padding(10)
                    .autocorrectionDisabled()
                Button("OK") {
                    Task {
                        let actors = await app.addVendor(newVendor)
                        DispatchQueue.main.async {
                            vendors = actors
                            if selectedVendor == nil, let first = vendors.first {
                                selectedVendor = first
                            }
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
            .buttonStyle(.link)

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
                // remove selection as one may have been selected previously if the
                // user watched a package from a different vendor
                selected = nil
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
