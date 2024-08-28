//
//  Places.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import MapKit

typealias Place = Places.PlaceDetail

struct Places: Decodable, Sendable {
    let places: [PlaceDetail]?
    
    struct PlaceDetail: Decodable, Sendable {
        let name: String?
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
        
        enum CodingKeys: String, CodingKey {
            case name
            case latitude = "lat"
            case longitude = "long"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case places = "locations"
    }
}

