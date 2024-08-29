//
//  MockURLSession.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import Foundation
@testable import WikipediaPlaces

struct MockURLSession: DataRequestable {
    private var dataResponse: (Data, URLResponse)?
    private var expectedRequest: URLRequest?

    mutating func setResponse(data: Data, response: URLResponse) {
        self.dataResponse = (data, response)
    }

    mutating func setExpectedRequest(_ request: URLRequest) {
        self.expectedRequest = request
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let expectedRequest {
            assert(request.url == expectedRequest.url, "Request URL does not match the expected URL.")
        }
        
        guard let response = dataResponse else {
            throw NetworkManagerError.invalidResponse
        }
        
        return response
    }
}

