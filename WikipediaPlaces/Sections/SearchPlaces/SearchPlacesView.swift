//
//  SearchPlacesView.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import SwiftUI

struct SearchPlacesView: View {
    @ObservedObject private var viewModel: SearchPlacesViewModel = .init()

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    placesList
                }
            }
            .navigationTitle("Search Places")
            .searchable(
                text: $viewModel.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("Search for a place...")
            )
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .overlay(
                searchButton,
                alignment: .bottom
            )
            .onAppear(perform: viewModel.viewIsReady)
        }
    }
    
    private var placesList: some View {
        List {
            Section(header: Text("Best Spot")) {
                if viewModel.isLoading && viewModel.places.isEmpty {
                    PlaceholderView(count: 3, text: "Loading Places...")
                } else {
                    ForEach(viewModel.places, id: \.name) { place in
                        Button {
                            if let name = place.name {
                                viewModel.openDetailsForPlace(with: name)
                            }
                        } label: {
                            Text(place.name ?? "Unknown place")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.5), value: viewModel.isLoading)
    }
    
    private var searchButton: some View {
        Button {
            viewModel.openDetailsForPlace(with: viewModel.query)
        } label: {
            Text(viewModel.searchButtonTitle)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isSearchButtonEnabled ? .blue : .gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
        .disabled(!viewModel.isSearchButtonEnabled)
    }
}

#Preview {
    SearchPlacesView()
}

