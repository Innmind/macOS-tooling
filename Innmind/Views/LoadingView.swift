//
//  LoadingView.swift
//  Innmind
//
//  Created by Baptouuuu on 14/11/2021.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        HStack() {
            Image(systemName: "arrow.triangle.2.circlepath.circle")
            Text("Loading...")
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
