//
//  ServicePropertyWrapper.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

/// A property wrapper that automatically resolves a service from the `ServiceContainer`.
/// It ensures that the service is resolved when the property is initialized.
///
/// The wrapped service type must conform to `Sendable`, ensuring it is safe to use in concurrent contexts.
@propertyWrapper
struct Service<Service: Sendable> {
    
    /// The resolved service instance.
    var service: Service
    
    /// Initializes the property wrapper by resolving the service from the `ServiceContainer`.
    ///
    /// - Parameter dependencyType: The type of service resolution (singleton, newInstance, or automatic).
    ///                              Defaults to `.automatic`.
    /// - Note: If the service is not registered in the `ServiceContainer`, this will cause a fatal error.
    init(_ dependencyType: ServiceType = .automatic) {
        guard let service = ServiceContainer.resolve(dependencyType: dependencyType, Service.self) else {
            fatalError("No dependency of type \(String(describing: Service.self)) registered!")
        }
        self.service = service
    }
    
    /// Provides access to the wrapped service.
    var wrappedValue: Service {
        get { self.service }
        mutating set { service = newValue }
    }
}

