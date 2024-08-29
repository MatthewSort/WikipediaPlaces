//
//  RequestProviderTests.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import XCTest
@testable import WikipediaPlaces

final class RequestProviderTests: XCTestCase {
    
    func testCreateRequestWithValidDataShouldReturnProperURLRequest() throws {
        let provider = RequestProvider()
        let url = URL(string: "https://example.com/test/path")!
        let mockData = "{\"key\":\"value\"}".data(using: .utf8)
        
        let route = MockRoute(
            path: "test/path",
            baseDomain: .places,
            queryItems: nil,
            httpMethod: .post,
            parameters: .data(data: mockData),
            contentType: .applicationJson,
            accept: .applicationJson
        )
        
        let request = try provider.createRequest(url: url, route: route)
        
        XCTAssertEqual(request.url?.absoluteString, "https://example.com/test/path")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(request.timeoutInterval, 30)
        XCTAssertEqual(request.httpBody, mockData)
    }
    
    func testCreateRequestWithoutParametersShouldReturnRequestWithoutBody() throws {
        let provider = RequestProvider()
        let url = URL(string: "https://example.com/test/path")!
        
        let route = MockRoute(
            path: "test/path",
            baseDomain: .places,
            queryItems: nil,
            httpMethod: .get,
            parameters: nil,
            contentType: .applicationJson,
            accept: .applicationJson
        )
        
        let request = try provider.createRequest(url: url, route: route)
        
        XCTAssertEqual(request.url?.absoluteString, "https://example.com/test/path")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(request.timeoutInterval, 30)
        XCTAssertNil(request.httpBody)
    }
    
    func testCreateRequestWithFormUrlEncodedDataShouldSetCorrectHeaders() throws {
        let provider = RequestProvider()
        let url = URL(string: "https://example.com/test/path")!
        let mockData = "key=value".data(using: .utf8)
        
        let route = MockRoute(
            path: "test/path",
            baseDomain: .places,
            queryItems: nil,
            httpMethod: .post,
            parameters: .data(data: mockData),
            contentType: .applicationFormUrlEncoded,
            accept: .applicationJson
        )
        
        let request = try provider.createRequest(url: url, route: route)
        
        XCTAssertEqual(request.url?.absoluteString, "https://example.com/test/path")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded")
        XCTAssertEqual(request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(request.timeoutInterval, 30)
        XCTAssertEqual(request.httpBody, mockData)
    }
    
    func testCreateRequestWithMultipartFormDataShouldSetCorrectHeaders() throws {
        let provider = RequestProvider()
        let url = URL(string: "https://example.com/test/path")!
        let mockData = "boundary=---exampleboundary".data(using: .utf8)
        let boundary = "exampleboundary"
        
        let route = MockRoute(
            path: "test/path",
            baseDomain: .places,
            queryItems: nil,
            httpMethod: .post,
            parameters: .data(data: mockData),
            contentType: .multipartFormData(boundary: boundary),
            accept: .applicationJson
        )
        
        let request = try provider.createRequest(url: url, route: route)
        
        XCTAssertEqual(request.url?.absoluteString, "https://example.com/test/path")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "multipart/form-data; boundary=\"exampleboundary\"")
        XCTAssertEqual(request.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(request.timeoutInterval, 30)
        XCTAssertEqual(request.httpBody, mockData)
    }
}
