//
//  BaseDomains.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

enum BaseDomains: Sendable {
    case places
    case none
    
    var basePath: String? {
        switch self {
        case .places:
            return Configuration.infoDictionaryKey(.BaseUrlPlaces).value
        case .none:
            return ""
        }
    }
}
