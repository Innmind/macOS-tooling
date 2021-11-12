//
//  SvgView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI
import WebKit

struct SvgView: View {
    var content: String

    init(content: String) {
        self.content = content
    }

    var body: some View {
        VStack {
            SvgWebView(content: content)
        }
    }
}

struct SvgWebView: NSViewRepresentable {
    var content: String

    func makeNSView(context: NSViewRepresentableContext<SvgWebView>) -> WKWebView {
        return WKWebView()
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<SvgWebView>) {
        nsView.allowsMagnification = true
        nsView.allowsBackForwardNavigationGestures = true
        nsView.loadHTMLString(content, baseURL: URL(string: "http://localhost/"))
    }
}

struct SvgView_Previews: PreviewProvider {
    static var previews: some View {
        SvgView(content: "</svg>")
    }
}
