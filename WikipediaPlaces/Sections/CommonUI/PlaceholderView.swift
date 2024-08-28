//
//  PlaceholderView.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import SwiftUI

struct PlaceholderView: View {
    let count: Int
    let text: String

    var body: some View {
        ForEach(0..<count, id: \.self) { _ in
            Text(text)
                .redacted(reason: .placeholder)
        }
    }
}
