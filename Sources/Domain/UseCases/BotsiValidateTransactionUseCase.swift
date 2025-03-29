//
//  BotsiValidateTransactionUseCase.swift
//  Botsi
//
//  Created by Vladyslav on 10.03.2025.
//

import Foundation

struct BotsiValidateTransactionUseCase {
    private let repository: BotsiValidateTransactionRepository

    init(repository: BotsiValidateTransactionRepository) {
        self.repository = repository
    }

    func validateTransaction(_ transaction: BotsiPaymentTransaction) async throws -> BotsiProfile {
        return try await repository.validateTransaction(transaction: transaction)
    }
}

// MARK: - CreateProfile request
struct ValidateTransactionRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: BotsiRequestIdentifier.validateTransaction)
    
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
