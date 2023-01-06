//
//  DependentsView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct DependentsView: View {
    @Binding var disableModifiers: Bool
    @Binding var zoom: Zoom
    let package: Vendor.Package
    @State private var content: Data? = nil

    var body: some View {
        VStack {
            if let content {
                SvgView(content: content, zoom: $zoom)
            } else {
                LoadingView()
            }
        }
            .navigationTitle(package.name)
            .task {
                disableModifiers = true
                self.content = await package.dependents()
                disableModifiers = false
            }
    }
}

struct DependentsView_Previews: PreviewProvider {
    static var previews: some View {
        DependentsView(disableModifiers: .constant(true), zoom: .constant(.max), package: .immutable)
    }
}
