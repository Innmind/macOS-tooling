//
//  VendorView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct VendorView: View {
    var body: some View {
        VStack {
            Text(organization.displayName).font(.title)
            SvgView(content: "<svg>vendor graph</svg>")
            Spacer()
        }
        .toolbar {
            Button(action: {}) {
                Image(systemName: "arrow.clockwise.circle")
                    .accessibilityLabel("Reload")
            }
        }
        .navigationTitle(organization.displayName)
    }
}

struct VendorView_Previews: PreviewProvider {
    static var previews: some View {
        VendorView()
    }
}
