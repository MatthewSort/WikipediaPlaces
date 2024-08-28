//
//  SearchPlacesView.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: SearchPlacesViewModel = .init()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear(perform: viewModel.viewIsReady)
    }
}

#Preview {
    ContentView()
}
