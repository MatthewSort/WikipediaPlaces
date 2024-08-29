//
//  NetworkManagerStatusCodeTests.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import XCTest
@testable import WikipediaPlaces

final class NetworkManagerStatusCodeTests: XCTestCase {
    
    func testNetworkManagerStatusCodeSubscript() {
        let successStatus: NetworkManagerStatusCode? = NetworkManagerStatusCode[200]
        let badRequestStatus: NetworkManagerStatusCode? = NetworkManagerStatusCode[400]
        let notFoundStatus: NetworkManagerStatusCode? = NetworkManagerStatusCode[404]
        let internalErrorStatus: NetworkManagerStatusCode? = NetworkManagerStatusCode[500]
        let unknownStatus: NetworkManagerStatusCode? = NetworkManagerStatusCode[999]
        
        XCTAssertEqual(successStatus, NetworkManagerStatusCode.success)
        XCTAssertEqual(badRequestStatus, NetworkManagerStatusCode.badRequest)
        XCTAssertEqual(notFoundStatus, NetworkManagerStatusCode.notFound)
        XCTAssertEqual(internalErrorStatus, NetworkManagerStatusCode.internalServerError)
        XCTAssertNil(unknownStatus)
    }
    
    func testNetworkManagerErrorSubscript() {
        let errorForSuccess = NetworkManagerStatusCode[200] as NetworkManagerError
        let errorForBadRequest = NetworkManagerStatusCode[400] as NetworkManagerError
        let errorForNotFound = NetworkManagerStatusCode[404] as NetworkManagerError
        let errorForInternalError = NetworkManagerStatusCode[500] as NetworkManagerError
        let errorForUnknown = NetworkManagerStatusCode[999] as NetworkManagerError
        
        XCTAssertEqual(errorForSuccess, .genericError)
        XCTAssertEqual(errorForBadRequest, .invalidURL)
        XCTAssertEqual(errorForNotFound, .invalidStatusCode)
        XCTAssertEqual(errorForInternalError, .internalError)
        XCTAssertEqual(errorForUnknown, .genericError)
    }
}
