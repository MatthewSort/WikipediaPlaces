//
//  Routable.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

protocol Routable {
    var path: String { get }
    var baseDomain: BaseDomains { get }
    var queryItems: [URLQueryItem]? { get }
    var httpMethod: HttpMethod { get }
    var parameters: APIResourceParameters? { get }
    var contentType: ContentType { get }
    var accept: ContentType { get }
}
