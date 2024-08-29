//
//  SearchButton.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 29/08/2024.
//

import SwiftUI

struct SearchButton: View {
    @ObservedObject var viewModel: SearchPlacesViewModel
    
    var body: some View {
        Button {
            viewModel.openDetailsForPlace(with: viewModel.query)
        } label: {
            Text(viewModel.searchButtonTitle)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isSearchButtonEnabled ? .blue : .gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
        .disabled(!viewModel.isSearchButtonEnabled)
    }
}
