//
//  BotsiGetPaywallUseCase.swift
//  Botsi
//
//  Created by Vladyslav on 22.03.2025.
//

import Foundation

struct BotsiGetPaywallUseCase {
    private let repository: BotsiGetPaywallRepository

    init(repository: BotsiGetPaywallRepository) {
        self.repository = repository
    }

    func execute(placementId: String) async throws -> BotsiPaywall {
        return try await repository.getPaywall(id: placementId)
    }
}

// MARK: - CreateProfile request
struct GetPaywallRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: BotsiRequestIdentifier.getPaywall)
    
    var method: BotsiHTTPMethod = .get
    
    var headers: [String: String] = [:]
    
    var body: Data? = nil
    
    private let placementId: String
    private let queryParameters: [String: String]?
    
    init(placementId: String, queryParameters: [String: String]? = nil) {
        self.placementId = placementId
        self.queryParameters = queryParameters
    }
    
    func convertToURLRequest(configuration: HTTPCodableConfiguration, additional: (any HTTPRequestAdditional)?) throws -> URLRequest {

        guard let url = url() else {
            throw BotsiError.networkError("Unable to build url request")
        }
        
        var urlComponents = URLComponents(string: url.absoluteString)
        urlComponents?.path += "/\(placementId)"
        
        if let queryParameters = queryParameters {
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let finalUrl = urlComponents?.url else {
            throw BotsiError.networkError("Unable to build final url request")
        }
        
        var request = URLRequest(url: finalUrl)
        
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}
