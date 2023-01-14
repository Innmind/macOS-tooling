//
//  VendorView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct VendorView: View {
    @Environment(\.openURL) var openUrl
    @EnvironmentObject var svg: Svg

    @State private var zoom: Zoom = .middle
    let vendor: Vendor

    var body: some View {
        VStack {
            if let content = svg.content {
                SvgView(content: content, zoom: $zoom)
            } else {
                LoadingView()
                    .onAppear {
                        self.svg.load()
                    }
            }
        }
        .toolbar {
            Button {openUrl(URL(string: "https://packagist.org/packages/"+self.vendor.name+"/")!)} label: {
                Text("Packagist")
            }
            Button {openUrl(URL(string: "https://github.com/"+self.vendor.name)!)} label: {
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
                .disabled(self.svg.content == nil)
            Button {
                self.svg.reload()
            } label: {
                Image(systemName: "arrow.clockwise.circle")
                    .accessibilityLabel("Reload Graph")
            }
                .disabled(self.svg.content == nil)
        }
    }
}
