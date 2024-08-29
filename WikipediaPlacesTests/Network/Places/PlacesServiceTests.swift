//
//  PlacesServiceTests.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import XCTest
@testable import WikipediaPlaces

final class PlacesServiceTests: XCTestCase {
    private var placesService: PlacesService!
    private var mockNetworkManager: MockNetworkManager!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        placesService = nil
        mockNetworkManager = nil
        super.tearDown()
    }

    func testGetPlacesSuccess() async {
        let placeDetail = Places.PlaceDetail(
            name: "Place Name",
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        let places = Places(places: [placeDetail])
        
        mockNetworkManager = MockNetworkManager(mockResult: .success(places))
        placesService = PlacesService(networkManager: mockNetworkManager)

        let result = await placesService.getPlaces()

        switch result {
        case .success(let retrievedPlaces):
            XCTAssertEqual(retrievedPlaces, places)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func testGetPlacesFailure() async {
        mockNetworkManager = MockNetworkManager(mockResult: .failure(.genericError))
        placesService = PlacesService(networkManager: mockNetworkManager)

        let result = await placesService.getPlaces()

        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error, .genericError)
        }
    }
}
