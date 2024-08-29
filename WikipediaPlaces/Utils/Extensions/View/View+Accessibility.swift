//
//  View+Accessibility.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 29/08/2024.
//

import SwiftUI

extension View {
    func setAccessibility(_ type: AccessibilityType) -> some View {
        let model = type.model
        return self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(model.label))
            .accessibilityValue(Text(model.value))
            .accessibilityHint(Text(model.hint))
            .accessibilityAddTraits(model.traits)
    }
}
