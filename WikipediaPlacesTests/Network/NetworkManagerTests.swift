//
//  NetworkManagerTests.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import XCTest
@testable import WikipediaPlaces

final class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var mockURLSession: MockURLSession!
    var mockURLProvider: MockEndpointURLProvider!
    var mockRequestProvider: MockRequestProvider!
    var mockCache: MockCache!
    
    private var url: URL? {
        URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/test/path")
    }

    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        mockURLProvider = MockEndpointURLProvider()
        mockRequestProvider = MockRequestProvider()
        mockCache = MockCache()

        networkManager = NetworkManager(
            urlSession: mockURLSession,
            urlProvider: mockURLProvider,
            requestProvider: mockRequestProvider,
            cache: mockCache
        )
    }

    func testSendRequestSuccessWithCache() async {
        let route = MockRoute(path: "test/path")
        let expectedPlace = Places.PlaceDetail(name: "Place Name", latitude: 37.7749, longitude: -122.4194)
        let expectedResponse = Places(places: [expectedPlace])
        let responseData: Data
        
        do {
            responseData = try JSONEncoder().encode(expectedResponse)
        } catch {
            XCTFail("Failed to encode expected response: \(error)")
            return
        }

        guard let url else {
            XCTFail("Invalid URL")
            return
        }

        guard let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
            XCTFail("Invalid Response")
            return
        }
        
        await mockURLSession.setResponse(data: responseData, response: httpResponse)

        await mockCache.insert(
            expectedResponse,
            forKey: url.absoluteString,
            timeToLiveInSeconds: 60
        )

        let result: Result<Places, NetworkManagerError> = await networkManager.sendRequest(
            route: route,
            cacheConfig: .active(),
            decodeTo: Places.self
        )

        switch result {
        case .success(let response):
            XCTAssertEqual(response, expectedResponse)
        case .failure(let error):
            XCTFail("Expected success, got error \(error)")
        }
    }
    
    func testSendRequestSuccessNoCache() async {
        let route = MockRoute(path: "test/path")
        let expectedPlace = Places.PlaceDetail(name: "Place Name", latitude: 37.7749, longitude: -122.4194)
        let expectedResponse = Places(places: [expectedPlace])
        
        let responseData: Data
        do {
            responseData = try JSONEncoder().encode(expectedResponse)
        } catch {
            XCTFail("Failed to encode expected response: \(error)")
            return
        }

        guard let url else {
            XCTFail("Invalid URL")
            return
        }
        
        guard let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
            XCTFail("Invalid Response")
            return
        }
        
        await mockURLSession.setExpectedRequest(URLRequest(url: url))
        await mockURLSession.setResponse(data: responseData, response: httpResponse)

        let result: Result<Places, NetworkManagerError> = await networkManager.sendRequest(
            route: route,
            cacheConfig: .none,
            decodeTo: Places.self
        )

        switch result {
        case .success(let response):
            XCTAssertEqual(response, expectedResponse)
        case .failure(let error):
            XCTFail("Expected success, got error \(error)")
        }
    }

    func testSendRequestFailure() async {
        let route = MockRoute(path: "test/path")
        
        guard let url else {
            XCTFail("Invalid URL")
            return
        }
        
        guard let httpResponse = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil) else {
            XCTFail("Invalid Response")
            return
        }
        
        await mockURLSession.setResponse(data: Data(), response: httpResponse)

        let result: Result<String, NetworkManagerError> = await networkManager.sendRequest(
            route: route,
            decodeTo: String.self
        )

        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            XCTAssertEqual(error, .internalError)
        }
    }

    func testSendRequestError() async {
        let route = MockRoute(path: "test/path")
        
        guard let url else {
            XCTFail("Invalid URL")
            return
        }
        
        guard let invalidData = "invalid".data(using: .utf8),
              let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
            XCTFail("Invalid Response")
            return
        }
        
        await mockURLSession.setResponse(data: invalidData, response: httpResponse)

        let result: Result<String, NetworkManagerError> = await networkManager.sendRequest(
            route: route,
            decodeTo: String.self
        )

        switch result {
        case .success:
            XCTFail("Expected decoding error, got success")
        case .failure(let error):
            XCTAssertEqual(error, .decodingError)
        }
    }
}
