//
//  AnySendableProtocol.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

/// A type-erased protocol that allows storing and retrieving any `Sendable` value.
protocol AnySendableProtocol: Sendable {
    func unwrap<T: Sendable>(as type: T.Type) -> T?
}

/// A type-erased wrapper that conforms to `AnySendableProtocol`.
struct AnySendable<T: Sendable>: AnySendableProtocol {
    private let value: T

    init(_ value: T) {
        self.value = value
    }

    func unwrap<U: Sendable>(as type: U.Type) -> U? {
        return value as? U
    }
}
