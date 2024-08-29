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
            Section(header: Text("Best Spot")
                .setAccessibility(.placeRow(name: "Best Spot"))
            ) {
                ForEach(viewModel.places, id: \.name) { place in
                    placeRow(place)
                        .setAccessibility(.placeRow(name: place.name ?? "Unknown Place"))
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
