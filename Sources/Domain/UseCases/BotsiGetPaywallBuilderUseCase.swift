//
//  BotsiGetPaywallBuilderUseCase.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 14.10.2025.
//

import Foundation

struct BotsiGetPaywallBuilderUseCase {
    private let repository: BotsiGetPaywallBuilderRepository

    init(repository: BotsiGetPaywallBuilderRepository) {
        self.repository = repository
    }

    func execute(paywallId: Int) async throws -> Data {
        return try await repository.getPaywallBuilder(paywallId: paywallId)
    }
}

struct GetPaywallBuilderRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: BotsiRequestIdentifier.getPaywallBuilder)
    
    var method: BotsiHTTPMethod = .get
    
    var headers: [String: String] = [:]
    
    var body: Data? = nil
    
    private let paywallId: Int
    private let queryParameters: [String: String]?
    
    init(paywallId: Int, queryParameters: [String: String]? = nil) {
        self.paywallId = paywallId
        self.queryParameters = queryParameters
    }
    
    func convertToURLRequest(configuration: HTTPCodableConfiguration, additional: (any HTTPRequestAdditional)?) throws -> URLRequest {

        guard let url = url() else {
            throw BotsiError.networkError("Unable to build url request")
        }
        
        var urlComponents = URLComponents(string: url.absoluteString)
        if let currentPath = urlComponents?.path {
            urlComponents?.path = currentPath.replacingOccurrences(of: "{paywallId}", with: "\(paywallId)")
        }
        
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
