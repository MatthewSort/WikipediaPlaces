//
//  ServiceContainer.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

enum ServiceType {
    case singleton
    case newInstance
    case automatic
}

final class ServiceContainer: Sendable {
    
    private static var cache: [String: AnySendableProtocol] = [:]
    private static var generators: [String: () -> AnySendableProtocol] = [:]
    
    /// Registers a service with the container.
    /// - Parameters:
    ///   - type: The service type to register.
    ///   - serviceType: The type of service registration (singleton, newInstance, or automatic).
    ///   - factory: A closure that creates the service.
    static func register<Service: Sendable>(
        type: Service.Type,
        as serviceType: ServiceType = .automatic,
        _ factory: @autoclosure @escaping () -> Service
    ) {
        let factoryWrapper: () -> AnySendableProtocol = { AnySendable(factory()) }
        generators[String(describing: type.self)] = factoryWrapper
        
        if serviceType == .singleton {
            cache[String(describing: type.self)] = factoryWrapper()
        }
    }
    
    /// Resolves a service from the container.
    /// - Parameters:
    ///   - dependencyType: The type of service resolution (singleton, newInstance, or automatic).
    ///   - type: The service type to resolve.
    /// - Returns: The resolved service, or `nil` if not found.
    static func resolve<Service: Sendable>(
        dependencyType: ServiceType = .automatic,
        _ type: Service.Type
    ) -> Service? {
        let key = String(describing: type.self)
        switch dependencyType {
        case .singleton:
            if let cachedService = cache[key]?.unwrap(as: Service.self) {
                return cachedService
            } else {
                fatalError("\(String(describing: type.self)) is not registered as singleton")
            }
            
        case .automatic:
            if let cachedService = cache[key]?.unwrap(as: Service.self) {
                return cachedService
            }
            fallthrough
            
        case .newInstance:
            if let service = generators[key]?().unwrap(as: Service.self) {
                cache[key] = AnySendable(service)
                return service
            } else {
                return nil
            }
        }
    }
    
    /// Removes a registered service from the container.
    /// - Parameter type: The type of service to remove.
    static func unregister<Service: Sendable>(type: Service.Type) {
        let key = String(describing: type.self)
        cache.removeValue(forKey: key)
        generators.removeValue(forKey: key)
    }
}
