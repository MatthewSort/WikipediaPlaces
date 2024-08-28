//
//  Configuration.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

enum Configuration {
    
    enum WikipediaInfoDictionaryKey: String {
        case BaseUrlPlaces
        case SchemaUrlWikipedia
    }
    
    case infoDictionaryKey(WikipediaInfoDictionaryKey)
    
    var value: String? {
        switch self {
        case .infoDictionaryKey(let wikipediaInfoDictionaryKey):
            return Bundle.main.object(forInfoDictionaryKey: wikipediaInfoDictionaryKey.rawValue) as? String
        }
        
    }
}
