//
//  MockRequestProvider.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import Foundation
@testable import WikipediaPlaces

struct MockRequestProvider: RequestProvidable {
    func createRequest(url: URL, route: Routable) throws -> URLRequest {
        return URLRequest(url: url)
    }
}
