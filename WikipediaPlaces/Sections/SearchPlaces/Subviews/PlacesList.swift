//
//  PlacesList.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 29/08/2024.
//

import SwiftUI

struct PlacesList: View {
    @ObservedObject var viewModel: SearchPlacesViewModel
    
    var body: some View {
        List {
            Section(header: Text("Best Spot")) {
                if viewModel.isLoading && viewModel.places.isEmpty {
                    PlaceholderView(count: 3, text: "Loading Places...")
                } else {
                    ForEach(viewModel.places, id: \.name) { place in
                        placeRow(place)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.5), value: viewModel.isLoading)
    }
    
    private func placeRow(_ place: Place) -> some View {
        Button {
            if let name = place.name {
                viewModel.openDetailsForPlace(with: name)
            }
        } label: {
            HStack {
                Text(place.name ?? "Unknown Place")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding(.vertical, 8)
        }
    }
}
