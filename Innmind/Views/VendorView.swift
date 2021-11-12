//
//  VendorView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct VendorView: View {
    @EnvironmentObject var svg: Svg

    let organization: Organization

    var body: some View {
        VStack {
            if (svg.loading) {
                HStack() {
                    Image(systemName: "arrow.triangle.2.circlepath.circle")
                    Text("Loading...")
                }
            } else {
                SvgView(content: svg.content!)
            }
        }
        .toolbar {
            Button(action: {}) {
                Image(systemName: "arrow.clockwise.circle")
                    .accessibilityLabel("Reload Graph")
            }
        }
        .navigationTitle(organization.displayName)
    }
}

struct VendorView_Previews: PreviewProvider {
    static var previews: some View {
        VendorView(organization: ModelData().organization).environmentObject(Svg(with: Organization(displayName: "Innmind", name: "innmind")))
    }
}
