//
//  NetworkManager.swift
//  WikipediaPlaces
//
//  Created by Mattia Capasso on 28/08/2024.
//

import Foundation

/// A protocol defining an interface for making data requests.
protocol DataRequestable: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Extension to make `URLSession` conform to `DataRequestable`.
extension URLSession: DataRequestable {}

/// A network manager responsible for sending requests, handling caching, and decoding responses.
final class NetworkManager: Sendable {
    private let urlSession: DataRequestable
    private let urlProvider: EndpointURLProvidable
    private let requestProvider: RequestProvidable
    private let cache: CustomCache<String>
    private let decoder: JSONDecoder = .init()
    
    /// Initialize NetworkManager with dependencies.
    ///
    /// - Parameters:
    ///   - urlSession: The session used to perform data requests.
    ///   - strategy: Strategy for decoding JSON responses.
    ///   - urlProvider: Provider to create endpoint URLs.
    ///   - requestProvider: Provider to create URL requests.
    ///   - cache: A custom cache for storing responses.
    init(urlSession: DataRequestable = URLSession.shared,
         strategy: DecodingStrategy = .default,
         urlProvider: EndpointURLProvidable = EndpointURLProvider(),
         requestProvider: RequestProvidable = RequestProvider(),
         cache: CustomCache<String> = CustomCache<String>()) {
        self.urlSession = urlSession
        self.urlProvider = urlProvider
        self.requestProvider = requestProvider
        self.cache = cache
        
        setupJSONDecoder(strategy: strategy)
    }
    
    /// Sends a network request, checking the cache first, and decodes the response.
    ///
    /// - Parameters:
    ///   - route: The route defining the request details.
    ///   - cacheConfig: Configuration for caching the response.
    ///   - decodeTo: The type to which the response should be decoded.
    /// - Returns: A result containing either the decoded response or an error.
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
    
    /// Configures the JSON decoder based on the specified strategy.
    ///
    /// - Parameter strategy: The strategy for decoding JSON data.
    private func setupJSONDecoder(strategy: DecodingStrategy) {
        decoder.dateDecodingStrategy = strategy.dateDecodingStrategy
        decoder.keyDecodingStrategy = strategy.keyDecodingStrategy
    }
    
    /// Performs the network request and decodes the response.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to be sent.
    ///   - decodeTo: The expected type of the decoded response.
    /// - Returns: The decoded response of type `D`.
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
    ///
    /// - Parameters:
    ///   - cacheConfig: The cache configuration.
    ///   - key: The key associated with the cached response.
    /// - Returns: The cached response of type `T`, or `nil` if not found or expired.
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
    ///
    /// - Parameters:
    ///   - result: The result to cache.
    ///   - key: The key associated with the cached response.
    ///   - cacheConfig: The cache configuration.
    func insertCachedResponse<T: Decodable & Sendable>(
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
    ///
    /// - Parameters:
    ///   - result: The result to cache, only cached if it is successful.
    ///   - key: The cache key to associate with the response.
    ///   - time: Optional TTL (time-to-live) in seconds, defaults to 90 seconds.
    private func insertResponseFromResult<T: Sendable, E: Error>(
        result: Result<T, E>,
        key: String,
        timeToLiveInSeconds time: Double = 90.0
    ) async {
        guard !key.isEmpty else { return }
        switch result {
        case let .success(response):
            await insertResponse(response: response, key: key, timeToLiveInSeconds: time)
        case .failure:
            break
        }
    }
    
    /// Inserts a response into the cache.
    ///
    /// - Parameters:
    ///   - response: The response to cache.
    ///   - key: The cache key to associate with the response.
    ///   - timeToLiveInSeconds: Optional TTL in seconds.
    private func insertResponse<T: Sendable>(response: T, key: String, timeToLiveInSeconds: Double) async {
        CustomLog.log("KEY CACHE INSERT: \(key)", logType: .debug)
        await cache.insert(response, forKey: key, timeToLiveInSeconds: timeToLiveInSeconds)
    }
    
    /// Resets the cache by reinitializing it.
    func resetCache() async {
        await cache.resetCache()
    }
    
    /// Logs the request for debugging purposes.
    ///
    /// - Parameter request: The `URLRequest` to be logged.
    private func logRequest(_ request: URLRequest) {
        let message = """
        [API] ----------------------------
        [API] REQUEST: \(request)
        [API] ----------------------------
        """
        CustomLog.log(message, logType: .debug)
    }
    
    /// Logs the cached response.
    ///
    /// - Parameter response: The cached response to be logged.
    private func logCacheResponse<D: Decodable>(_ response: D) {
        CustomLog.log("RESPONSE FROM CACHE: \(response)", logType: .debug)
    }
    
    /// Logs the API response status.
    ///
    /// - Parameter response: The `HTTPURLResponse` to be logged.
    private func logAPIResponse(_ response: HTTPURLResponse) {
        CustomLog.log("RESPONSE API: \(response)", logType: .debug)
    }
    
    /// Logs the raw data received from the API.
    ///
    /// - Parameter data: The raw data to be logged.
    private func logRawData(_ data: Data) {
        if let dataString = String(data: data, encoding: .utf8) {
            CustomLog.log("RAW DATA: \(dataString)", logType: .debug)
        }
    }
}


