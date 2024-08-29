//
//  MockEndpointURLProvider.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import Foundation
@testable import WikipediaPlaces

struct MockEndpointURLProvider: EndpointURLProvidable {
    func createEndpointURL(baseURL: URL, route: Routable) throws -> URL {
        return baseURL.appendingPathComponent(route.path)
    }
}
