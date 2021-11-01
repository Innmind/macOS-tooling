//
//  PackageGraphs.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI
import WebKit

struct PackageGraphs: View {
    var package: Package
    
    var body: some View {
        VStack {
            Text("innmind/"+self.package.name).font(.title)
            Text("tab group here for each kind of graph")
            SvgView(content: "</svg>")
            Spacer()
        }
            .padding(5)
            .navigationTitle(self.package.name)
    }
}
/*
struct SvgView: NSViewRepresentable {
    var content: String

    func makeNSView(context: NSViewRepresentableContext<SvgView>) -> WKWebView {
        let svg = WKWebView()
        //svg.load(URLRequest(url: URL(string: "data:image/svg;base64,"+content)!))

        return svg
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<SvgView>) {
        nsView.load(URLRequest(url: URL(string: "https://github.com")!))
    }
}*/

struct PackageGraphs_Previews: PreviewProvider {
    static var previews: some View {
        PackageGraphs(package: packages[0])
    }
}
