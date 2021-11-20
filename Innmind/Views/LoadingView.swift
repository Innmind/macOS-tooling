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
            ProgressView()
                .scaleEffect(0.5)
            Text("Loading...")
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
