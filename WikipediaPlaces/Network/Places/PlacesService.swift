//
//  PlacesService.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

protocol PlacesServing: Actor, Sendable {
    func getPlaces() async -> Result<Places, NetworkManagerError>
}

actor PlacesService: PlacesServing {
    private let networkManager: NetworkManagerServing
    
    init(networkManager: NetworkManagerServing = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func getPlaces() async -> Result<Places, NetworkManagerError> {
        let route: PlacesRoute = .getPlaces
        return await networkManager.sendRequest(
            route: route, 
            cacheConfig: .active(),
            decodeTo: Places.self
        )
    }
}
