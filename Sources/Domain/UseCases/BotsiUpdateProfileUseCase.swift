//
//  BotsiUpdateProfileUseCase.swift
//  Botsi
//
//  Created by Vladyslav on 27.05.2025.
//

import Foundation

struct BotsiUpdateProfileUseCase {
    private let repository: BotsiUpdateProfileRepository

    init(repository: BotsiUpdateProfileRepository) {
        self.repository = repository
    }

    func execute(identifier: String, ip: String) async throws -> BotsiProfile {
        return try await repository.updateUserProfile(identifier: identifier, ip: ip)
    }
}

struct UpdateProfileRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: BotsiRequestIdentifier.createProfile)
    
    var method: BotsiHTTPMethod = .patch
    
    var headers: [String: String] = [:]
    
    var body: Data? = nil
    
    private let uuid: String
    
    init(uuid: String) {
        self.uuid = uuid
    }
    
    func convertToURLRequest(configuration: HTTPCodableConfiguration, additional: (any HTTPRequestAdditional)?) throws -> URLRequest {

        guard let url = url() else {
            throw BotsiError.networkError("Unable to build url request")
        }
        
        var urlComponents = URLComponents(string: url.absoluteString)
        urlComponents?.path += "/\(uuid)"
        
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
