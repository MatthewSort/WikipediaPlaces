//
//  SearchPlacesView.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import SwiftUI

struct SearchPlacesView: View {
    @StateObject private var viewModel: SearchPlacesViewModel = .init()

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    PlacesList(viewModel: viewModel)
                }
            }
            .navigationTitle("Search Places")
            .searchable(
                text: $viewModel.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("Search for a place...")
            )
            .customAlert(
                alertContent: $viewModel.alertContent,
                isPresented: $viewModel.showAlert
            )
            .overlay(
                SearchButton(viewModel: viewModel),
                alignment: .bottom
            )
            .task {
                await viewModel.loadPlaces()
            }
        }
    }
}

#Preview {
    SearchPlacesView()
}

