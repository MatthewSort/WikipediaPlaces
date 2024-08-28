//
//  SearchPlacesViewModel.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

@MainActor
final class SearchPlacesViewModel: ObservableObject {
    @Published var places: [Place] = []
    
    @Service private var placesService: PlacesServing
    
    func viewIsReady() {
        Task {
            await loadPlaces()
        }
    }
    
    private func loadPlaces() async {
        let result = await placesService.getPlaces()
        
        switch result {
        case .success(let response):
            places = response.places ?? []
        case .failure:
            places = []
        }
    }
}
