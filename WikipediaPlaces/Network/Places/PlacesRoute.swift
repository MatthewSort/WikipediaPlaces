//
//  PlacesRoute.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

enum PlacesRoute: Routable {
    case getPlaces
    
    var baseDomain: BaseDomains {
        .places
    }
    
    var path: String {
        switch self {
        case .getPlaces:
            return "main/locations.json"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .getPlaces:
            return .get
        }
    }
    
    var parameters: APIResourceParameters? {
        return nil
    }
    
    var contentType: ContentType {
        return .applicationJson
    }
    
    var accept: ContentType {
        return .applicationJson
    }
}
