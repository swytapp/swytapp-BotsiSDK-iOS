//
//  BotsiUpdateRefundConsentUseCase.swift
//  Botsi
//
//  Created by Vladyslav on 19.07.2025.
//

import Foundation

struct BotsiUpdateRefundConsentUseCase {
    private let repository: BotsiUpdateRefundConsentRepository

    init(repository: BotsiUpdateRefundConsentRepository) {
        self.repository = repository
    }

    func execute(profileId: String, consent: Bool) async throws {
        return try await repository.updateRefundConsent(for: profileId, consent: consent)
    }
}

struct UpdateRefundConsentRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: BotsiRequestIdentifier.createProfile)
    
    var method: BotsiHTTPMethod = .patch
    
    var headers: [String: String] = [:]
    
    var body: Data? = nil
    
    private let profileId: String
    
    init(profileId: String) {
        self.profileId = profileId
    }
    
    func convertToURLRequest(configuration: HTTPCodableConfiguration, additional: (any HTTPRequestAdditional)?) throws -> URLRequest {

        guard let url = url() else {
            throw BotsiError.networkError("Unable to build url request")
        }
        
        var urlComponents = URLComponents(string: url.absoluteString)
        urlComponents?.path += "/\(profileId)/apple-consumption-consent"
        
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
