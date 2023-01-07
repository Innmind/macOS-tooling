//
//  DependenciesView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct DependenciesView: View {
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

