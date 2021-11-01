//
//  DependentsView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct DependentsView: View {
    var package: Package
    
    var body: some View {
        VStack {
            Text("Dependents")
            Text("innmind/"+self.package.name).font(.title)
            SvgView(content: "</svg>")
            Spacer()
        }
            .padding(5)
            .navigationTitle(self.package.name)
    }
}

struct DependentsView_Previews: PreviewProvider {
    static var previews: some View {
        DependentsView(package: packages[0])
    }
}
