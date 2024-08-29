//
//  CustomCache.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

/// An enum that defines the configuration options for the custom cache system.
enum CustomCacheConfig {
    /// Represents a configuration where caching is disabled.
    case none
    
    /// Represents a configuration where caching is active.
    /// - Parameters:
    ///   - ttl: Time-to-live (TTL) for cached entries, specified in seconds.
    ///          This determines how long the cached items should remain valid.
    ///          The default TTL is 90 seconds.
    case active(ttl: Double = 90.0)
}

protocol Cacheable: Actor, Sendable {
    /// Inserts a value into the cache with a specific time-to-live.
    /// - Parameters:
    ///   - value: The value to be cached.
    ///   - key: The key to associate with the cached value.
    ///   - timeToLiveInSeconds: The expiration time in seconds.
    func insert<T: Sendable>(_ value: T, forKey key: String, timeToLiveInSeconds: Double)
    
    /// Retrieves a value from the cache for the specified key.
    /// - Parameters:
    ///   - key: The key associated with the cached value.
    ///   - type: The expected type of the cached value.
    /// - Returns: The cached value, or `nil` if the value has expired or doesn't exist.
    func value<T: Sendable>(forKey key: String, as type: T.Type) -> T?
    
    /// Removes a value from the cache for the specified key.
    /// - Parameter key: The key associated with the value to be removed.
    func removeValue(forKey key: String)
    
    /// Clears the entire cache.
    func resetCache()
}

actor CustomCache: Cacheable {
    private var cache: [KeyWrapper: CacheEntry] = [:]
    private var discardFlags: [KeyWrapper: Bool] = [:]

    /// Class that represents each cache entry, allowing for discardable content.
    private final class CacheEntry: Sendable {
        let value: AnySendableProtocol
        let expiryDate: Date?

        init(value: AnySendableProtocol, expiryDate: Date? = nil) {
            self.value = value
            self.expiryDate = expiryDate
        }
        
        /// Checks if the content is valid (i.e., not expired).
        func isValid() -> Bool {
            guard let expiryDate = expiryDate else { return true }
            return Date().compare(expiryDate) == .orderedAscending
        }
    }

    /// Wrapper class for the cache keys to allow the use of hashable keys in the dictionary.
    private struct KeyWrapper: Hashable, Sendable {
        private let key: String

        init(_ key: String) {
            self.key = key
        }

        func hash(into hasher: inout Hasher) {
            key.hash(into: &hasher)
        }

        static func ==(lhs: KeyWrapper, rhs: KeyWrapper) -> Bool {
            return lhs.key == rhs.key
        }
    }

    func insert<T: Sendable>(_ value: T, forKey key: String, timeToLiveInSeconds: Double) {
        let expiryDate = Date().addingTimeInterval(timeToLiveInSeconds)
        let entry = CacheEntry(value: AnySendable(value), expiryDate: expiryDate)
        let wrappedKey = KeyWrapper(key)
        
        cache[wrappedKey] = entry
        discardFlags[wrappedKey] = false
    }
    
    func insert<T: Sendable>(_ value: T, forKey key: String) {
        let entry = CacheEntry(value: AnySendable(value))
        let wrappedKey = KeyWrapper(key)
        cache[wrappedKey] = entry
        discardFlags[wrappedKey] = false
    }

    func value<T: Sendable>(forKey key: String, as type: T.Type) -> T? {
        let wrappedKey = KeyWrapper(key)
        guard let entry = cache[wrappedKey], entry.isValid() else {
            removeValue(forKey: key)
            return nil
        }
        
        discardFlags[wrappedKey] = false
        return entry.value.unwrap(as: T.self)
    }

    func discardContent(forKey key: String) {
        let wrappedKey = KeyWrapper(key)
        discardFlags[wrappedKey] = true
        cache[wrappedKey] = nil
    }

    func removeValue(forKey key: String) {
        let wrappedKey = KeyWrapper(key)
        cache.removeValue(forKey: wrappedKey)
        discardFlags.removeValue(forKey: wrappedKey)
    }

    func resetCache() {
        cache.removeAll()
        discardFlags.removeAll()
    }
}



