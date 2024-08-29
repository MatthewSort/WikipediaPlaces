//
//  EndpointURLProviderTests.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import XCTest
@testable import WikipediaPlaces

final class EndpointURLProviderTests: XCTestCase {

    func testCreateEndpointURLwithValidRouteShouldReturnValidURL() throws {
        let provider = EndpointURLProvider()
        guard let baseURL = URL(string: "https://example.com") else {
            XCTFail("Failed to create baseURL")
            return
        }
        
        let route = MockRoute(
            path: "test/path",
            baseDomain: .places,
            queryItems: [URLQueryItem(name: "key", value: "value")],
            httpMethod: .get,
            parameters: nil,
            contentType: .applicationJson,
            accept: .applicationJson
        )

        do {
            let result = try provider.createEndpointURL(baseURL: baseURL, route: route)
            XCTAssertEqual(result.absoluteString, "https://example.com/test/path?key=value")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateEndpointURLwithInvalidBaseURLshouldThrowError() {
        let provider = EndpointURLProvider()
        let baseURL = URL(string: "invalidurl")!
        let route = MockRoute(
            path: "test/path",
            baseDomain: .none,
            queryItems: nil,
            httpMethod: .get,
            parameters: nil,
            contentType: .applicationJson,
            accept: .applicationJson
        )
        
        XCTAssertThrowsError(try provider.createEndpointURL(baseURL: baseURL, route: route)) { error in
            XCTAssertEqual(error as? NetworkManagerError, NetworkManagerError.invalidURL)
        }
    }
}

