//
//  BotsiRestorePurchaseUseCase.swift
//  Botsi
//
//  Created by Vladyslav on 15.03.2025.
//

import Foundation

struct BotsiRestorePurchaseUseCase {
    private let repository: BotsiRestorePurchaseRepository

    init(repository: BotsiRestorePurchaseRepository) {
        self.repository = repository
    }

    /*func execute(transaction: BotsiPaymentTransaction) async throws -> BotsiProfile {
        return try await repository.restore(transaction: transaction)
    }*/
    
    func execute(profileId: String, receipt: Data) async throws -> BotsiProfile {
        return try await repository.restore(receipt: receipt)
    }
}

// MARK: - Sync transaction request (restore)
struct RestorePurchaseRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: BotsiRequestIdentifier.restorePurchases)
    
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
