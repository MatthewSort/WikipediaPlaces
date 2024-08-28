import SwiftUI

@MainActor
final class SearchPlacesViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var query: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    @Service private var placesService: PlacesServing
    
    var isSearchButtonEnabled: Bool {
        !query.isEmpty
    }

    var searchButtonTitle: String {
        "Search \(query)"
    }

    func viewIsReady() {
        Task {
            await loadPlaces()
        }
    }

    private func loadPlaces() async {
        isLoading = true
        
        let result = await placesService.getPlaces()
        
        switch result {
        case .success(let response):
            places = response.places ?? []
        case .failure:
            alertMessage = "Failed to load places. Please try again later."
            showAlert = true
            places = []
        }
        
        isLoading = false
    }

    func openDetailsForPlace(with name: String) {
        guard let placeName = name.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let schemaUrl = Configuration.infoDictionaryKey(.SchemaUrlWikipedia).value,
              let urlToOpen = URL(string: schemaUrl + placeName) else {
            
            displayError("The URL is invalid or the place name has invalid character")
            return
        }
        
        CustomLog.log("URL: \(urlToOpen)")
        UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
    }

    private func displayError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}


