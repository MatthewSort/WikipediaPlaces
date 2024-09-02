//
//  MockCache.swift
//  WikipediaPlacesTests
//
//  Created by Mattia Capasso on 29/08/2024.
//

import Foundation
@testable import WikipediaPlaces

actor MockCache: Cacheable {
    private var store: [String: AnySendableProtocol] = [:]

    func insert<T: Sendable>(_ value: T, forKey key: String, timeToLiveInSeconds: Double? = nil) {
        store[key] = AnySendable(value)
    }

    func value<T: Sendable>(forKey key: String, as type: T.Type) -> T? {
        return (store[key] as? AnySendable<T>)?.unwrap(as: T.self)
    }

    func removeValue(forKey key: String) {
        store.removeValue(forKey: key)
    }

    func resetCache() {
        store.removeAll()
    }
}
