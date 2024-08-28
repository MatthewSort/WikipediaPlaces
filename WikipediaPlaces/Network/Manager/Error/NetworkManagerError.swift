//
//  NetworkManagerError.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

enum NetworkManagerError: String, Error {
    case invalidURL
    case invalidResponse
    case invalidStatusCode
    case encodingError
    case decodingError
    case internalError
    case genericError
    case serverError
    case rateLimit
    case invalidParameters
    case noDataFound
    
    var message: String {
        switch self {
        default:
            return String(localized: "Oops! Looks like there are problems, try again later. \(self.rawValue.uppercased()) 🤯")
        }
    }
}
