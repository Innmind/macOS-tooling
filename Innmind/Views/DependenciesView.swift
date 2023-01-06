//
//  DependenciesView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct DependenciesView: View {
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
                self.content = await package.dependencies()
                disableModifiers = false
            }
    }
}

struct DependenciesView_Previews: PreviewProvider {
    static var previews: some View {
        DependenciesView(disableModifiers: .constant(true), zoom: .constant(.max), package: .immutable)

    }
}
