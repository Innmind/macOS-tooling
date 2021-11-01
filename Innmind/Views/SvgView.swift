//
//  SvgView.swift
//  Innmind
//
//  Created by Baptouuuu on 01/11/2021.
//

import SwiftUI

struct SvgView: View {
    var content: String

    var body: some View {
        VStack {
            Text("Svg graph will be displayed here")
            Text("of content: "+content)
        }
    }
}

struct SvgView_Previews: PreviewProvider {
    static var previews: some View {
        SvgView(content: "</svg>")
    }
}
