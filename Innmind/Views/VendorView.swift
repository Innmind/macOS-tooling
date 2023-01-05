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

    var body: some View {
        VStack {
            switch self.svg.content {
            case nil:
                LoadingView()
            default:
                SvgView(content: self.svg.content!, zoom: $zoom)
            }
        }
        .toolbar {
            Button(action: {openUrl(URL(string: "https://packagist.org/packages/"+self.svg.name+"/")!)}) {
                Text("Packagist")
            }
            Button(action: {openUrl(URL(string: "https://github.com/"+self.svg.name)!)}) {
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
            Button(action: {
                svg.reload()
            }) {
                Image(systemName: "arrow.clockwise.circle")
                    .accessibilityLabel("Reload Graph")
            }
                .disabled(self.svg.content == nil)
        }
        .navigationTitle(self.svg.name)
        .onAppear {
            self.svg.load()
        }
    }
}

struct VendorView_Previews: PreviewProvider {
    static var previews: some View {
        VendorView().environmentObject(Svg.organization(Organization(displayName: "Innmind", name: "innmind")))
    }
}
