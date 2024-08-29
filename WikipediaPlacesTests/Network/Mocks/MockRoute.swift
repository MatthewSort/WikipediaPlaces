//
//  MockRoute.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import Foundation
@testable import WikipediaPlaces

struct MockRoute: Routable {
    var path: String
    var baseDomain: BaseDomains
    var queryItems: [URLQueryItem]?
    var httpMethod: HttpMethod
    var parameters: APIResourceParameters?
    var contentType: ContentType
    var accept: ContentType
    
    init(
        path: String = "",
        baseDomain: BaseDomains = .places,
        queryItems: [URLQueryItem]? = nil,
        httpMethod: HttpMethod = .get,
        parameters: APIResourceParameters? = nil,
        contentType: ContentType = .applicationJson,
        accept: ContentType = .applicationJson
    ) {
        self.path = path
        self.baseDomain = baseDomain
        self.queryItems = queryItems
        self.httpMethod = httpMethod
        self.parameters = parameters
        self.contentType = contentType
        self.accept = accept
    }
}
