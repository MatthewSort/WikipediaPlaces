//
//  MockNetworkManager.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import XCTest
@testable import WikipediaPlaces

actor MockNetworkManager: NetworkManagerServing {
    private let mockResult: Result<Places, NetworkManagerError>

    init(mockResult: Result<Places, NetworkManagerError>) {
        self.mockResult = mockResult
    }

    func sendRequest<D: Decodable & Sendable>(
        route: Routable,
        cacheConfig: CustomCacheConfig,
        decodeTo type: D.Type
    ) async -> Result<D, NetworkManagerError> {
        guard let decodedResponse = mockResult as? Result<D, NetworkManagerError> else {
            fatalError("Mock result type mismatch")
        }
        
        return decodedResponse
    }
}
