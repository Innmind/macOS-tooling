//
//  VendorView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct VendorView: View {
    @EnvironmentObject var svg: Svg

    @State private var zoom: Zoom = .middle

    var body: some View {
        VStack {
            switch self.svg.content {
            case nil:
                HStack() {
                    Image(systemName: "arrow.triangle.2.circlepath.circle")
                    Text("Loading...")
                }
            default:
                SvgView(content: self.svg.content!, zoom: $zoom)
            }
        }
        .toolbar {
            Picker("", selection: $zoom) {
                Text(Zoom.min.name()).tag(Zoom.min)
                Text(Zoom.middle.name()).tag(Zoom.middle)
                Text(Zoom.max.name()).tag(Zoom.max)
            }
                .pickerStyle(SegmentedPickerStyle())
            Button(action: {
                svg.reload()
            }) {
                Image(systemName: "arrow.clockwise.circle")
                    .accessibilityLabel("Reload Graph")
            }
        }
        .navigationTitle(self.svg.name)
    }
}

struct VendorView_Previews: PreviewProvider {
    static var previews: some View {
        VendorView().environmentObject(Svg.organization(Organization(displayName: "Innmind", name: "innmind")))
    }
}
