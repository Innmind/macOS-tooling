//
//  DependentsView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct DependentsView: View {
    @EnvironmentObject var svg: Svg

    @Binding var disableModifiers: Bool
    @Binding var zoom: Zoom
    
    var body: some View {
        VStack {
            switch self.svg.content {
            case nil:
                LoadingView()
                    .onAppear {
                        disableModifiers = true
                        self.svg.load()
                    }
            default:
                SvgView(content: self.svg.content!, zoom: $zoom)
                    .onAppear {
                        disableModifiers = false
                    }
            }
        }
            .navigationTitle(self.svg.name)
    }
}

struct DependentsView_Previews: PreviewProvider {
    static var previews: some View {
        DependentsView(disableModifiers: .constant(true), zoom: .constant(.max))
    }
}
