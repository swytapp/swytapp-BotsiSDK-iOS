//
//  BotsiASATokenUseCase.swift
//  Botsi
//
//  Created by Vladyslav on 07.05.2025.
//

import Foundation

struct BotsiASATokenUseCase {
    private let repository: BotsiASATokenRepository

    init(repository: BotsiASATokenRepository) {
        self.repository = repository
    }

    func execute(profileId: String, token: String) async throws -> BotsiProfile {
        return try await repository.sendASAToken(profileId: profileId, token: token)
    }
}

struct SendASATokenRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: BotsiRequestIdentifier.asaToken)
    
    var method: BotsiHTTPMethod = .post
    
    var headers: [String: String] = [:]
    
    var body: Data? = nil
    
    private let queryParameters: [String: String]?
    
    init(queryParameters: [String: String]? = nil) {
        self.queryParameters = queryParameters
    }
    
    func convertToURLRequest(configuration: HTTPCodableConfiguration, additional: (any HTTPRequestAdditional)?) throws -> URLRequest {

        guard let url = url() else {
            throw BotsiError.networkError("Unable to build url request")
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}
