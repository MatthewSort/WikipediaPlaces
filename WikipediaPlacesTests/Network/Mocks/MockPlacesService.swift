//
//  MockPlacesService.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

@testable import WikipediaPlaces

actor MockPlacesService: PlacesServing {
    private var mockResult: Result<Places, NetworkManagerError>
    
    init(mockResult: Result<Places, NetworkManagerError>) {
        self.mockResult = mockResult
    }
    
    func setResult(_ result: Result<Places, NetworkManagerError>) {
        mockResult = result
    }
    
    func getPlaces() async -> Result<Places, NetworkManagerError> {
        return mockResult
    }
}
