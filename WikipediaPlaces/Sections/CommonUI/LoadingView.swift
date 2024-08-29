//
//  LoadingView.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
                .padding()
        }
        .setAccessibility(.loading)
    }
}
