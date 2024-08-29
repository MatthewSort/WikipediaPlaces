//
//  EndpointURLProvider.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

protocol EndpointURLProvidable: Sendable {
    func createEndpointURL(baseURL: URL, route: Routable) throws -> URL
}

struct EndpointURLProvider: EndpointURLProvidable {
    func createEndpointURL(baseURL: URL, route: Routable) throws -> URL {
        let url = baseURL.appendingPathComponent(route.path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = route.queryItems
        
        guard let endpointURL = components?.url, isValidURL(endpointURL) else {
            throw NetworkManagerError.invalidURL
        }
        
        return endpointURL
    }
    
    private func isValidURL(_ url: URL) -> Bool {
        return url.scheme != nil && url.host != nil
    }
}
