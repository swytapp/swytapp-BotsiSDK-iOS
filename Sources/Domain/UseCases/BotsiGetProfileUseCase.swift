//
//  BotsiGetProfileUseCase.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//

import Foundation

struct BotsiGetProfileUseCase {
    private let repository: BotsiGetProfileRepository

    init(repository: BotsiGetProfileRepository) {
        self.repository = repository
    }

    func execute(identifier: String) async throws -> BotsiProfile {
        return try await repository.getUserProfile(identifier: identifier)
    }
}

// MARK: - CreateProfile request
struct GetProfileRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: .createProfile)
    
    var method: BotsiHTTPMethod = .get
    
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
