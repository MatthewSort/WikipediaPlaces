//
//  ContentType.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

/// Enum defines the the request content type from API service
enum ContentType {
    /// Used when sending JSON data in the request body.
    /// Commonly used for RESTful APIs where the client sends JSON data to the server.
    case applicationJson
    
    /// Used when uploading files or binary data along with other form data.
    /// The `boundary` parameter is necessary to separate the different parts of the data.
    /// Typically used in file uploads or when submitting forms that include files.
    case multipartFormData(boundary: String)
    
    /// Used when sending form data as key-value pairs in the request body.
    /// Commonly used in simple form submissions where data is encoded as a query string.
    case applicationFormUrlEncoded

    var value: String {
        switch self {
        case .applicationJson:
            return "application/json"
        case .multipartFormData(let boundary):
            return "multipart/form-data; boundary=\"\(boundary)\""
        case .applicationFormUrlEncoded:
            return "application/x-www-form-urlencoded"
        }
    }

    static let header: String = "Content-Type"
}
