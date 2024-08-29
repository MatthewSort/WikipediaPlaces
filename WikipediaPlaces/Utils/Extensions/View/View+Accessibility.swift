//
//  View+Accessibility.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 29/08/2024.
//

import SwiftUI

struct AccessibilityModifier: ViewModifier {
    let type: AccessibilityType

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(type.model.label))
            .accessibilityValue(Text(type.model.value))
            .accessibilityHint(Text(type.model.hint))
            .accessibilityAddTraits(type.model.trait)
    }
}

extension View {
    func setAccessibility(_ type: AccessibilityType) -> some View {
        self.modifier(AccessibilityModifier(type: type))
    }
}
