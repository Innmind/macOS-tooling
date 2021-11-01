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
            Text("Innmind").font(.title)
            SvgView(content: "<svg>vendor graph</svg>")
            Spacer()
        }
    }
}

struct VendorView_Previews: PreviewProvider {
    static var previews: some View {
        VendorView()
    }
}
