//
//  ContentView.swift
//  Innmind
//
//  Created by Baptouuuu on 31/10/2021.
//

import SwiftUI

struct Package: Hashable {
    let name: String
}

struct ContentView: View {
    @State var currentPackage = 0

    var packages: [Package] = [
        .init(name: "Innmind"),
        .init(name: "immutable"),
        .init(name: "time-continuum"),
        .init(name: "filesystem"),
    ]

    var body: some View {
        NavigationView {
            ListView(
                packages: packages,
                selectedPackage: $currentPackage
            )
                .frame(minWidth: 100)

            switch currentPackage {
            case 0:
                VendorView()
            default:
                MainView(package: self.packages[currentPackage])
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct ListView : View {
    let packages: [Package]
    @Binding var selectedPackage: Int

    var body: some View {
        ScrollView {
            let current = packages[selectedPackage]
            ForEach(packages.indices, id: \.self) { index in
                HStack {
                    Text(packages[index].name)
                        .foregroundColor(current == packages[index] ? Color.primary : Color.secondary)
                    Spacer()
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .onTapGesture {
                    selectedPackage = index
                }
                Divider()
            }
            Spacer()
        }
    }
}

struct MainView : View {
    let package: Package

    var body: some View {
        VStack {
            Text("innmind/"+self.package.name).font(.title)
            Spacer()
        }
        .padding(5)
    }
}

struct VendorView : View {
    var body: some View {
        VStack {
            Text("Innmind").font(.title)
            Text("vendor graph here")
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
