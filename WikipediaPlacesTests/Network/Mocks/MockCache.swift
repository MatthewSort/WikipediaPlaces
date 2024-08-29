//
//  MockCache.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import Foundation
@testable import WikipediaPlaces

actor MockCache: Cacheable {
    private var store: [String: Any] = [:]

    func insert<T: Sendable>(_ value: T, forKey key: String, timeToLiveInSeconds: Double) {
        store[key] = value
    }

    func value<T: Sendable>(forKey key: String, as type: T.Type) -> T? {
        return store[key] as? T
    }

    func removeValue(forKey key: String) {
        store.removeValue(forKey: key)
    }

    func resetCache() {
        store.removeAll()
    }
}
