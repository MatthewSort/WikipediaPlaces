//
//  WikipediaPlacesApp.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import SwiftUI

@main
struct WikipediaPlacesApp: App {
    
    init() {
        setupDependencyContainer()
    }
    
    var body: some Scene {
        WindowGroup {
            SearchPlacesView()
        }
    }
    
    private func setupDependencyContainer() {
        ServiceContainer.register(type: PlacesServing.self, PlacesService())
    }
}
