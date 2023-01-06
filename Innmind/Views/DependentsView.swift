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
            if let content = svg.content {
                SvgView(content: content, zoom: $zoom)
                    .onAppear {
                        disableModifiers = false
                    }
            } else {
                LoadingView()
                    .onAppear {
                        disableModifiers = true
                        self.svg.load()
                    }
            }
        }
    }
}

struct DependentsView_Previews: PreviewProvider {
    static var previews: some View {
        DependentsView(disableModifiers: .constant(true), zoom: .constant(.max))
            .environmentObject(Svg.dependents(.immutable))
    }
}
