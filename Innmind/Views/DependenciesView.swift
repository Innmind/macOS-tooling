//
//  DependenciesView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct DependenciesView: View {
    var package: Package
    
    var body: some View {
        VStack {
            SvgView(content: "</svg>")
        }
            .padding(5)
            .navigationTitle(self.package.name)
    }
}

struct DependenciesView_Previews: PreviewProvider {
    static var model = ModelData()

    static var previews: some View {
        DependenciesView(package: model.packages[0])
    }
}
