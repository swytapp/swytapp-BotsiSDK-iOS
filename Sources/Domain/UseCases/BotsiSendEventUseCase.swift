//
//  BotsiSendEventUseCase.swift
//  Botsi
//
//  Created by Vladyslav on 25.03.2025.
//

import Foundation

struct BotsiSendEventUseCase {
    private let repository: BotsiEventsRepository

    init(repository: BotsiEventsRepository) {
        self.repository = repository
    }

    func execute(profileId: String, placementId: String, eventType: String) async throws {
        return try await repository.sendEvent(profileId: profileId, placementId: placementId, eventType: eventType)
    }
}


// MARK: - events request
struct SendEventRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: BotsiRequestIdentifier.events)
    
    var method: BotsiHTTPMethod = .post
    
    var headers: [String: String] = [:]
    
    var body: Data? = nil
    
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
