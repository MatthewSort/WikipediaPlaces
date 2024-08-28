//
//  PlacesService.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

protocol PlacesServing: Sendable {
    func getPlaces() async -> Result<Places, NetworkManagerError>
}

final class PlacesService: PlacesServing {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .init()) {
        self.networkManager = networkManager
    }
    
    func getPlaces() async -> Result<Places, NetworkManagerError> {
        let route: PlacesRoute = .getPlaces
        return await networkManager.sendRequest(
            route: route,
            decodeTo: Places.self
        )
    }
}
