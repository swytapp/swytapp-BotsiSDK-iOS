//
//  BotsiSignPromotionalOfferUseCase.swift
//  Botsi
//
//  Created by Vladyslav on 19.04.2025.
//

import Foundation

struct SignPromotionalOfferUseCase {
    private let repository: SignPromotionalOfferRepository

    init(repository: SignPromotionalOfferRepository) {
        self.repository = repository
    }

    func getSignedPromotionalOffer() async throws -> BotsiSignSubscriptionOfferResponseData {
        return try await repository.getSignedPromotionalOffer()
    }
}

struct SignPromotionalOfferRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: BotsiRequestIdentifier.signPromotionalOffer)
    
    var method: BotsiHTTPMethod = .get
    
    var headers: [String: String] = [:]
    
    var body: Data? = nil
    
    private let queryParameters: [String: String]
    
    init(queryParameters: [String: String]) {
        self.queryParameters = queryParameters
    }
    
    func convertToURLRequest(configuration: HTTPCodableConfiguration, additional: (any HTTPRequestAdditional)?) throws -> URLRequest {

        guard let url = url() else {
            throw BotsiError.networkError("Unable to build url request")
        }
        
        var urlComponents = URLComponents(string: url.absoluteString)
        urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
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
