//
//  SearchPlacesViewModelTests.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 29/08/2024.
//

import XCTest
import SwiftUI
@testable import WikipediaPlaces

final class SearchPlacesViewModelTests: XCTestCase {
    private var viewModel: SearchPlacesViewModel!
    private var mockUIApplication: MockUIApplication!
    private var placesService: MockPlacesService!

    @MainActor override func setUp() {
        super.setUp()
        
        ServiceContainer.unregister(type: PlacesServing.self)
        ServiceContainer.register(
            type: PlacesServing.self,
            as: .automatic,
            MockPlacesService(mockResult: .success(Places(places: [])))
        )
        
        if let resolvedService = ServiceContainer.resolve(dependencyType: .automatic, PlacesServing.self) as? MockPlacesService {
            placesService = resolvedService
        } else {
            fatalError("Failed to resolve MockPlacesService from ServiceContainer")
        }
        
        mockUIApplication = MockUIApplication()
        viewModel = SearchPlacesViewModel(application: mockUIApplication)
    }
    
    override func tearDown() {
        ServiceContainer.unregister(type: PlacesServing.self)
        ServiceContainer.register(type: PlacesServing.self, as: .automatic, PlacesService())
        viewModel = nil
        mockUIApplication = nil
        
        super.tearDown()
    }
    
    func testLoadPlacesSuccess() async {
        let expectedPlace = Places.PlaceDetail(name: "Place Name", latitude: 37.7749, longitude: -122.4194)
        let expectedResponse = Places(places: [expectedPlace])
        
        await placesService.setResult(.success(expectedResponse))
        await viewModel.loadPlaces()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.places, [expectedPlace])
        XCTAssertFalse(viewModel.showAlert)
    }
    
    func testLoadPlacesFailure() async {
        await placesService.setResult(.failure(.genericError))
        await viewModel.loadPlaces()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.places.isEmpty)
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertContent.title, "Error")
        XCTAssertEqual(viewModel.alertContent.message, "Failed to load places. Please try again later.")
    }
    
    func testOpenDetailsForPlaceSuccess() {
        let name = "Test Place"
        guard let placeName = name.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let schemaUrl = Configuration.infoDictionaryKey(.SchemaUrlWikipedia).value,
              let expectedURL = URL(string: schemaUrl + placeName) else {
            XCTFail("The URL is invalid or the place name has invalid character")
            return
        }
        
        viewModel.openDetailsForPlace(with: name)
        
        XCTAssertEqual(mockUIApplication.openedURL, expectedURL)
    }
    
    func testOpenDetailsForPlaceFailure() {
        let name = "Test Place"
        guard let placeName = name.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let schemaUrl = Configuration.infoDictionaryKey(.SchemaUrlWikipedia).value,
              let expectedURL = URL(string: schemaUrl + placeName) else {
            XCTFail("The URL is invalid or the place name has invalid character")
            return
        }
        
        mockUIApplication.shouldOpenURL = false
        viewModel.openDetailsForPlace(with: name)
        
        XCTAssertTrue(viewModel.showAlert)
        XCTAssertEqual(viewModel.alertContent.title, "Error")
        XCTAssertEqual(viewModel.alertContent.message, "The URL wikipedia://places?WMFArticleURL=https://en.wikipedia.org/wiki/Test%20Place could not be opened. Please try again.")
    }
}
