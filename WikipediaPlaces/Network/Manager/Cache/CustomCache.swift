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

/// A protocol that defines the basic caching operations.
protocol Cacheable: Actor, Sendable {
    /// Inserts a value into the cache with a specific time-to-live.
    /// - Parameters:
    ///   - value: The value to be cached.
    ///   - key: The key to associate with the cached value.
    ///   - timeToLiveInSeconds: The expiration time in seconds.
    func insert<T: Sendable>(_ value: T, forKey key: String, timeToLiveInSeconds: Double?)
    
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

/// A custom cache implementation that uses NSCache to manage cached values with optional expiration dates.
actor CustomCache: Cacheable {
    private let cache = NSCache<KeyWrapper, CacheEntry>()

    init() {
        /// Prevents NSCache from automatically evicting objects that have been marked as discarded.
        /// This ensures that even if an object is flagged as discarded (e.g., expired), it remains in the cache
        /// until explicitly removed. This is useful for managing custom eviction logic, such as checking expiration dates
        /// or performing other cleanup tasks before removal.
        cache.evictsObjectsWithDiscardedContent = false
    }

    /// A wrapper class for cache entries, allowing for optional expiration dates.
    private final class CacheEntry: NSDiscardableContent {
        let value: AnySendableProtocol
        let expiryDate: Date?
        private var isDiscarded = false

        init(value: AnySendableProtocol, expiryDate: Date? = nil) {
            self.value = value
            self.expiryDate = expiryDate
        }

        /// Marks the content as accessed and checks if it is still valid.
        func beginContentAccess() -> Bool {
            let today = Date()
            guard let expiryDate, today.compare(expiryDate) == .orderedAscending else {
                isDiscarded = false
                return isDiscarded
            }

            isDiscarded = true
            return false
        }

        /// Called when content access is finished.
        func endContentAccess() {
            /// Handle any logic when content access ends, if necessary.
        }

        /// Discards the content if it is no longer needed.
        func discardContentIfPossible() {
            isDiscarded = true
        }

        /// Checks if the content has been discarded.
        func isContentDiscarded() -> Bool {
            return isDiscarded
        }
    }

    /// A wrapper class for cache keys to support NSCache's object keys.
    private final class KeyWrapper: NSObject {
        let key: String

        init(_ key: String) {
            self.key = key
        }

        override var hash: Int {
            return key.hashValue
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? KeyWrapper else { return false }
            return other.key == key
        }
    }

    func insert<T: Sendable>(_ value: T, forKey key: String, timeToLiveInSeconds: Double? = nil) {
        let expiryDate = timeToLiveInSeconds.map { Date().addingTimeInterval($0) }
        let entry = CacheEntry(value: AnySendable(value), expiryDate: expiryDate)
        cache.setObject(entry, forKey: KeyWrapper(key))
    }

    func value<T: Sendable>(forKey key: String, as type: T.Type) -> T? {
        let today = Date()

        guard let entry = cache.object(forKey: KeyWrapper(key)) else {
            return nil
        }

        if let expiryDate = entry.expiryDate {
            if today.compare(expiryDate) != .orderedAscending {
                removeValue(forKey: key)
                return nil
            }
        }

        return (entry.value as? AnySendable<T>)?.unwrap(as: T.self)
    }

    func removeValue(forKey key: String) {
        cache.removeObject(forKey: KeyWrapper(key))
    }

    func resetCache() {
        cache.removeAllObjects()
    }
}
