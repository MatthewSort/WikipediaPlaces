//
//  SearchPlacesViewModel.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import SwiftUI

final class SearchPlacesViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var query: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertContent: CustomAlertContent = .empty

    @Service private var placesService: PlacesServing
    private var application: UIApplicationServing
    
    init(application: UIApplicationServing = UIApplication.shared) {
        self.application = application
    }
    
    var isSearchButtonEnabled: Bool {
        !query.isEmpty
    }

    var searchButtonTitle: String {
        "Search \(query)"
    }
    
    @MainActor
    func loadPlaces() async {
       isLoading = true
       
       let result = await placesService.getPlaces()
       
       switch result {
       case .success(let response):
           places = response.places?.filter { $0.name != nil } ?? []
       case .failure:
           showRetryAlert(
               message: "Failed to load places. Please try again later.",
               retryAction: { [weak self] in
                   self?.retryToLoadPlaces()
               }
           )
           places = []
       }
       
       isLoading = false
   }

    func openDetailsForPlace(with name: String) {
        guard let placeName = name.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let schemaUrl = Configuration.infoDictionaryKey(.SchemaUrlWikipedia).value,
              let urlToOpen = URL(string: schemaUrl + placeName) else {
            
            retryOpenDetailsForPlace(
                with: name,
                message: "The URL is invalid or the place name has invalid character"
            )
            return
        }
        
        CustomLog.log("URL: \(urlToOpen)")
        
        application.open(urlToOpen, options: [:]) { [weak self] success in
            if !success {
                self?.retryOpenDetailsForPlace(
                    with: name,
                    message: "The URL \(urlToOpen.absoluteString) could not be opened. Please try again."
                )
            }
        }
    }
    
    private func retryToLoadPlaces() {
        Task { @MainActor in
            await loadPlaces()
        }
    }
    
    private func retryOpenDetailsForPlace(with name: String, message: String) {
        showRetryAlert(
            message: message,
            retryAction: { [weak self] in
                self?.openDetailsForPlace(with: name)
            }
        )
    }
    
    private func showRetryAlert(
        title: String = "Error",
        message: String,
        retryAction: @escaping () -> Void
    ) {
        alertContent = CustomAlertContent(
            title: title,
            message: message,
            primaryButton: .default(Text("Retry"), action: retryAction),
            secondaryButton: .cancel(Text("Continue"))
        )
        
        showAlert = true
    }
}



