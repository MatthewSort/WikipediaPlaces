//
//  CustomCacheTests.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import XCTest
@testable import WikipediaPlaces

final class CustomCacheTests: XCTestCase {
    var cache: CustomCache!

    override func setUp() {
        super.setUp()
        cache = CustomCache()
    }

    func testInsertAndRetrieveValue() async {
        let key = "testKey"
        let value = "testValue"
        
        await cache.insert(value, forKey: key, timeToLiveInSeconds: 60)
        
        let retrievedValue: String? = await cache.value(forKey: key, as: String.self)
        XCTAssertEqual(retrievedValue, value)
    }

    func testInsertWithNoTTL() async {
        let key = "testKeyNoTTL"
        let value = "testValueNoTTL"
        
        await cache.insert(value, forKey: key)
        
        let retrievedValue: String? = await cache.value(forKey: key, as: String.self)
        XCTAssertEqual(retrievedValue, value)
    }

    func testExpiredValue() async {
        let key = "testKeyExpired"
        let value = "testValueExpired"
        
        await cache.insert(value, forKey: key, timeToLiveInSeconds: 0)
        
        let retrievedValue: String? = await cache.value(forKey: key, as: String.self)
        XCTAssertNil(retrievedValue)
    }

    func testRemoveValue() async {
        let key = "testKeyToRemove"
        let value = "testValueToRemove"
        
        await cache.insert(value, forKey: key)
        await cache.removeValue(forKey: key)
        
        let retrievedValue: String? = await cache.value(forKey: key, as: String.self)
        XCTAssertNil(retrievedValue)
    }

    func testResetCache() async {
        let key1 = "testKey1"
        let value1 = "testValue1"
        let key2 = "testKey2"
        let value2 = "testValue2"
        
        await cache.insert(value1, forKey: key1)
        await cache.insert(value2, forKey: key2)
        await cache.resetCache()
        
        let retrievedValue1: String? = await cache.value(forKey: key1, as: String.self)
        let retrievedValue2: String? = await cache.value(forKey: key2, as: String.self)
        
        XCTAssertNil(retrievedValue1)
        XCTAssertNil(retrievedValue2)
    }
}
