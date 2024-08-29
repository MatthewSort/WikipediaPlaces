//
//  NetworkManager.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

// A protocol defining an interface for making data requests.
protocol DataRequestable: Sendable {
    /// Fetches data and response for a given URL request.
    /// - Parameter request: The URL request to be sent.
    /// - Returns: A tuple containing the data and URL response.
    /// - Throws: An error if the request fails.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Extension to make `URLSession` conform to `DataRequestable`.
extension URLSession: DataRequestable {}

protocol NetworkManagerServing: Actor, Sendable {
    
    /// Sends a network request, checking the cache first, and decodes the response.
    /// - Parameters:
    ///   - route: The route describing the endpoint to request.
    ///   - cacheConfig: Configuration for caching. Defaults to `.active()`.
    ///   - decodeTo: The type to decode the response data into.
    /// - Returns: A result containing either the decoded response or a network error.
    func sendRequest<D: Decodable & Sendable>(
        route: Routable,
        cacheConfig: CustomCacheConfig,
        decodeTo type: D.Type
    ) async -> Result<D, NetworkManagerError>
}

/// A network manager responsible for sending requests, handling caching, and decoding responses.
actor NetworkManager: NetworkManagerServing {
    private let urlSession: DataRequestable
    private let urlProvider: EndpointURLProvidable
    private let requestProvider: RequestProvidable
    private let cache: any Cacheable
    private let decoder: JSONDecoder = .init()

    /// Initializes `NetworkManager` with dependencies.
    /// - Parameters:
    ///   - urlSession: The session to use for data tasks. Defaults to `URLSession.shared`.
    ///   - urlProvider: The provider that generates endpoint URLs. Defaults to `EndpointURLProvider()`.
    ///   - requestProvider: The provider that creates URL requests. Defaults to `RequestProvider()`.
    ///   - cache: The cache instance for storing and retrieving cached responses. Defaults to `CustomCache()`.
    init(
        urlSession: DataRequestable = URLSession.shared,
        urlProvider: EndpointURLProvidable = EndpointURLProvider(),
        requestProvider: RequestProvidable = RequestProvider(),
        cache: any Cacheable = CustomCache()
    ) {
        self.urlSession = urlSession
        self.urlProvider = urlProvider
        self.requestProvider = requestProvider
        self.cache = cache
    }

    func sendRequest<D: Decodable & Sendable>(
        route: Routable,
        cacheConfig: CustomCacheConfig = .active(),
        decodeTo: D.Type
    ) async -> Result<D, NetworkManagerError> {
        guard let basePath = route.baseDomain.basePath,
              let baseURL = URL(string: basePath) else {
            return .failure(.invalidURL)
        }

        do {
            let endpointURL = try urlProvider.createEndpointURL(baseURL: baseURL, route: route)
            let request = try requestProvider.createRequest(url: endpointURL, route: route)

            logRequest(request)

            if let cachedResponse: D = await checkForCachedResponse(
                cacheConfig: cacheConfig,
                key: endpointURL.absoluteString
            ) {
                logCacheResponse(cachedResponse)
                return .success(cachedResponse)
            }

            let responseData = try await performRequest(request: request, decodeTo: decodeTo)
            let responseResult: Result<D, NetworkManagerError> = .success(responseData)

            await insertCachedResponse(
                responseResult,
                key: endpointURL.absoluteString,
                cacheConfig: cacheConfig
            )

            return responseResult
        } catch let error as NetworkManagerError {
            return .failure(error)
        } catch {
            return .failure(.genericError)
        }
    }

    /// Performs the network request and decodes the response.
    /// - Parameters:
    ///   - request: The URL request to be sent.
    ///   - decodeTo: The type to decode the response data into.
    /// - Returns: The decoded response data.
    /// - Throws: An error if the request fails or decoding fails.
    private func performRequest<D: Decodable & Sendable>(
        request: URLRequest,
        decodeTo: D.Type
    ) async throws -> D {
        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkManagerError.invalidResponse
        }

        logAPIResponse(httpResponse)

        guard NetworkManagerStatusCode[httpResponse.statusCode] == .success else {
            throw NetworkManagerStatusCode[httpResponse.statusCode]
        }

        logRawData(data)

        do {
            return try decoder.decode(D.self, from: data)
        } catch {
            throw NetworkManagerError.decodingError
        }
    }

    /// Checks if a cached response is available for the given key.
    /// - Parameters:
    ///   - cacheConfig: Configuration for caching.
    ///   - key: The key associated with the cached response.
    /// - Returns: The cached response if available, otherwise `nil`.
    private func checkForCachedResponse<T: Decodable & Sendable>(
        cacheConfig: CustomCacheConfig,
        key: String
    ) async -> T? {
        guard case .active = cacheConfig else {
            return nil
        }

        CustomLog.log("KEY CACHE RESPONSE: \(key)", logType: .debug)

        return await cache.value(forKey: key, as: T.self)
    }

    /// Inserts a response into the cache based on cache configuration.
    /// - Parameters:
    ///   - result: The result of the network request.
    ///   - key: The key to associate with the cached response.
    ///   - cacheConfig: Configuration for caching.
    private func insertCachedResponse<T: Decodable & Sendable>(
        _ result: Result<T, NetworkManagerError>,
        key: String,
        cacheConfig: CustomCacheConfig
    ) async {
        guard case let .active(ttl) = cacheConfig else {
            return
        }

        await insertResponseFromResult(result: result, key: key, timeToLiveInSeconds: ttl)
    }

    /// Inserts a result into the cache if the result is successful.
    /// - Parameters:
    ///   - result: The result of the network request.
    ///   - key: The key to associate with the cached response.
    ///   - timeToLiveInSeconds: The expiration time in seconds.
    private func insertResponseFromResult<T: Sendable, E: Error>(
        result: Result<T, E>,
        key: String,
        timeToLiveInSeconds: Double = 90.0
    ) async {
        guard !key.isEmpty else { return }
        switch result {
        case let .success(response):
            await insertResponse(
                response: response,
                key: key,
                timeToLiveInSeconds: timeToLiveInSeconds
            )
        case .failure:
            break
        }
    }

    /// Inserts a response into the cache.
    /// - Parameters:
    ///   - response: The response data to be cached.
    ///   - key: The key to associate with the cached response.
    ///   - timeToLiveInSeconds: The expiration time in seconds.
    private func insertResponse<T: Sendable>(response: T, key: String, timeToLiveInSeconds: Double) async {
        CustomLog.log("KEY CACHE INSERT: \(key)", logType: .debug)
        await cache.insert(response, forKey: key, timeToLiveInSeconds: timeToLiveInSeconds)
    }

    private func logRequest(_ request: URLRequest) {
        let message = """
        [API] ----------------------------
        [API] REQUEST: \(request)
        [API] ----------------------------
        """
        CustomLog.log(message, logType: .debug)
    }

    private func logCacheResponse<D: Decodable>(_ response: D) {
        CustomLog.log("RESPONSE FROM CACHE: \(response)", logType: .debug)
    }

    private func logAPIResponse(_ response: HTTPURLResponse) {
        CustomLog.log("RESPONSE API: \(response)", logType: .debug)
    }

    private func logRawData(_ data: Data) {
        if let dataString = String(data: data, encoding: .utf8) {
            CustomLog.log("RAW DATA: \(dataString)", logType: .debug)
        }
    }
}
