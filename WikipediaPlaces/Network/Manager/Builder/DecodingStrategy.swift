//
//  DecodingStrategy.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

/// A settable decoding strategy that is helpful to customise key and date decoding for any request
struct DecodingStrategy {
    internal let keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
    internal let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    
    /// A *default* ``DecodingStrategy`` that uses the already default key (JSONDecoder.KeyDecodingStrategy)
    /// and date (JSONDecoder.DateDecodingStrategy.deferredToDate) decoding strategies.
    static var `default`: DecodingStrategy {
        .init(keyDecodingStrategy: .useDefaultKeys, dateDecodingStrategy: .deferredToDate)
    }
    
    /// A ``DecodingStrategy`` that uses a **JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase**
    /// *key* and **JSONDecoder.DateDecodingStrategy.millisecondsSince1970** *date* decoding strategy.
    static var snakeCaseAndMilliseconds: DecodingStrategy {
        .init(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .millisecondsSince1970)
    }
    
    init(
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    ) {
        self.keyDecodingStrategy = keyDecodingStrategy
        self.dateDecodingStrategy = dateDecodingStrategy
    }
}
