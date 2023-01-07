//
//  VendorView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct VendorView: View {
    @Environment(\.openURL) var openUrl

    @State private var zoom: Zoom = .middle
    @State private var content: Data?
    let vendor: Vendor

    var body: some View {
        VStack {
            if let content {
                SvgView(content: content, zoom: $zoom)
            } else {
                LoadingView()
            }
        }
        .toolbar {
            Button(action: {openUrl(URL(string: "https://packagist.org/packages/"+self.vendor.name+"/")!)}) {
                Text("Packagist")
            }
            Button(action: {openUrl(URL(string: "https://github.com/"+self.vendor.name)!)}) {
                Text("Github")
            }
            HStack {
                Divider()
            }
            Picker("", selection: $zoom) {
                Text(Zoom.min.name()).tag(Zoom.min)
                Text(Zoom.middle.name()).tag(Zoom.middle)
                Text(Zoom.max.name()).tag(Zoom.max)
            }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(self.content == nil)
            Button(action: {
                content = nil
                Task {
                    await vendor.reload()
                }
            }) {
                Image(systemName: "arrow.clockwise.circle")
                    .accessibilityLabel("Reload Graph")
            }
                .disabled(self.content == nil)
        }
        .task {
            self.content = await vendor.svg()
        }
    }
}
