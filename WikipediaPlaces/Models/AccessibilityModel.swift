//
//  AccessibilityModel.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 29/08/2024.
//

import SwiftUI
import Foundation

struct AccessibilityModel {
    let label: String
    var value = ""
    var hint = ""
    var trait: AccessibilityTraits = .allowsDirectInteraction
}

enum AccessibilityType {
    case loading
    case searchButton(isEnabled: Bool)
    case placeRow(name: String)
    case alert(title: String, message: String?)

    var model: AccessibilityModel {
        switch self {
        case .loading:
            return AccessibilityModel(
                label: "Loading view",
                hint: "Loading content. Please wait."
            )
        case .searchButton(let isEnabled):
            return AccessibilityModel(
                label: "Search button",
                hint: isEnabled ? "Tap to search for places." : "Search button is disabled.",
                trait: isEnabled ? .isButton : .allowsDirectInteraction
            )
        case .placeRow(let name):
            return AccessibilityModel(
                label: name,
                hint: "Tap to view details.",
                trait: .isButton
            )
        case .alert(let title, let message):
            return AccessibilityModel(
                label: title,
                value: message ?? "",
                hint: "Alert message: \(message ?? "")"
            )
        }
    }
}


