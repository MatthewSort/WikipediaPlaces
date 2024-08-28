//
//  NetworkManagerStatusCode.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

enum NetworkManagerStatusCode: Int {
    case success = 200
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case timeout = 408
    case conflict = 409
    case rateLimit = 429
    case internalServerError = 500
    
    static subscript(statusCode: Int) -> NetworkManagerStatusCode? {
        return NetworkManagerStatusCode(rawValue: statusCode)
    }
    
    static subscript(statusCode: Int) -> NetworkManagerError {
        switch NetworkManagerStatusCode(rawValue: statusCode) {
        case .notFound:
            return .invalidStatusCode
        case .badRequest, .forbidden, .unauthorized, .methodNotAllowed, .timeout, .conflict:
            return .invalidURL
        case .internalServerError:
            return .internalError
        case .rateLimit:
            return .rateLimit
        case .none, .some(.success):
            return .genericError
        }
    }
}
