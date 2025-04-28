//
//  BotsiOfferEligibilityUseCase.swift
//  Botsi
//
//  Created by Vladyslav on 26.04.2025.
//

import Foundation

struct OfferEligibilityUseCase {
    private let repository: OfferEligibilityRepository

    init(repository: OfferEligibilityRepository) {
        self.repository = repository
    }

    func getEligibleOffers(profileId: String, productIds: [String]) async throws -> [BotsiOfferEligibilityData] {
        return try await repository.getElligibleOffers(profileId: profileId, productIds: productIds)
    }
}

struct OfferEligibilityRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: BotsiRequestIdentifier.offerEligibility)
    
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
