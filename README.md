# WikipediaPlaces | ABN AMRO | iOS ASSIGNMENT
A SwiftUI application that allows users to view locations on a map via the Wikipedia app using deep linking. Users can select locations from a pre-defined list or enter custom locations, which are then passed to the Wikipedia app to be displayed on the 'Places' tab.

<p align="center">
  <img src="https://github.com/user-attachments/assets/2024136b-27e4-44a0-b55c-e72af4630425" alt="Wikipedia_Places_Logo 1">
</p>


## Overview

The `WikipediaPlaces` app demonstrates how to integrate deep linking to interact with the Wikipedia app. When a user selects a location or enters a custom location, the Wikipedia app is launched and navigates directly to the specified location on the 'Places' tab.

## Features

- **Location List**: Fetches a list of locations from a remote JSON endpoint.
- **Custom Location Entry**: Allows users to enter and search for custom locations.
- **Deep Linking**: Opens the Wikipedia app and navigates to the specified location.
- **Accessibility**: Includes UI Accessibility.

## Demo
https://github.com/user-attachments/assets/8426b582-0d48-47ff-9fe6-2ef1c13f7116


## Architecture

### MVVM Pattern

The app utilizes the Model-View-ViewModel (MVVM) architecture. This separation ensures a clear distinction between the user interface (View) and the business logic/data transformation (ViewModel).

- **Model**: Represents the data structure, including the `Places` and `PlaceDetail` models.
- **View**: Built using SwiftUI, responsible for rendering the user interface.
- **ViewModel**: Manages the data and logic for interacting with the network layer and updating the view.

### Dependency Injection

Dependency injection is used to manage dependencies, such as the `PlacesService`, through a service container. This approach simplifies testing and improves modularity.

### Swift Concurrency

- **Strict Concurrency**: The app uses Swift Concurrency features with strict concurrency settings (`Targeted`) to ensure safe and efficient concurrent code execution. Strict concurrency helps avoid data races and makes code easier to reason about.
- **Actors and `Sendable` Protocol**: Actors are used for managing concurrency in network operations, and the `Sendable` protocol ensures that types used in concurrent contexts are safe to be shared across threads.

## API Used

The app fetches locations from the following endpoint:

- [Locations JSON](https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json)

### Unit Tests

The unit tests are written to validate the functionality of different components and services in the application. The test suite has achieved a code coverage of 91%. The tests include:

1. **Network Layer Tests**:
   - **`NetworkManagerTests`**: Tests the `NetworkManager` for different scenarios, including success with and without cache, and failure cases.
   - **`NetworkManagerStatusCodeTests`**: Verifies the correct mapping of status codes to errors and ensures proper handling of various HTTP status codes.

2. **Cache Tests**:
   - **`CustomCacheTests`**: Tests the `CustomCache` for inserting, retrieving, removing, and resetting cache values, as well as handling cache expiration.

3. **Service Layer Tests**:
   - **`PlacesServiceTests`**: Tests the `PlacesService` for handling success and failure scenarios when fetching places.

4. **ViewModel Tests**:
   - **`SearchPlacesViewModelTests`**: Tests the `SearchPlacesViewModel` for loading places successfully, handling errors, and opening URLs for place details.

## Test Setup

### Test Dependencies

- **Mocks**:
  - `MockRoute`, `MockCache`, `MockURLSession`, `MockEndpointURLProvider`, `MockRequestProvider`, `MockNetworkManager`, `MockPlacesService`, `MockUIApplication` are used to simulate various components and behaviors for testing.

## UI/Automated Tests

Currently, the project includes unit tests but does not have UI or snapshot tests. Future improvements may include adding automated UI tests.

## Device Support

- **Platform**: iPhone & iPad
- **Orientation**: Portrait & Landscape
- **Minimum iOS Version**: iOS 17.0

## Styles and Design

The design of the app focuses on functionality and usability. Styles are minimal but consistent. Future updates may include enhanced styling and UI improvements.

## Xcode Version

- **Xcode Version**: 15.4
