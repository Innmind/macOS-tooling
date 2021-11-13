//
//  SvgView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI
import WebKit

struct SvgView: View {
    var content: Data
    @Binding var zoom: Zoom

    var body: some View {
        VStack {
            SvgWebView(content: content, zoom: zoom)
        }
    }
}

struct SvgWebView: NSViewRepresentable {
    var content: Data
    var zoom: Zoom

    func makeNSView(context: NSViewRepresentableContext<SvgWebView>) -> WKWebView {
        return WKWebView()
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<SvgWebView>) {
        nsView.allowsMagnification = true
        nsView.allowsBackForwardNavigationGestures = true
        nsView.pageZoom = zoom.toCGFloat()
        nsView.loadHTMLString(String(decoding: content, as: UTF8.self), baseURL: URL(string: "http://localhost/"))
    }
}

struct SvgView_Previews: PreviewProvider {
    static var previews: some View {
        SvgView(content: "</svg>".data(using: .utf8)!, zoom: .constant(.max))
    }
}
