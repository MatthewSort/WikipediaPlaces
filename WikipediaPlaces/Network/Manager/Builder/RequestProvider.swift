//
//  RequestProvider.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

protocol RequestProvidable: Sendable {
    func createRequest(url: URL, route: Routable) throws -> URLRequest
}

struct RequestProvider: RequestProvidable {
    func createRequest(url: URL, route: Routable) throws -> URLRequest {
        var request = URLRequest(url: url)
        
        request.addValue(route.contentType.value, forHTTPHeaderField: "Content-Type")
        request.addValue(route.accept.value, forHTTPHeaderField: "Accept")
        
        request.httpMethod = route.httpMethod.rawValue
        request.timeoutInterval = 30
        
        if let parameters = route.parameters {
            if case let .data(data) = parameters {
                request.httpBody = data
            }
        }
        
        return request
    }
}
