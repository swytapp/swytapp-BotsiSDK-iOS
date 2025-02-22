//
//  BotsiHTTPResponseWrapper.swift
//  Botsi
//
//  Created by Vladyslav on 22.02.2025.
//

import Foundation

fileprivate struct HTTPDecoderHelper {
    private let jsonDecoder: JSONDecoder
    
    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
    }
    
    /// Decodes data into a specified type
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw BotsiHTTPDecodingError.decodingFailed(error.localizedDescription)
        }
    }
}

/// Custom decoding errors
enum BotsiHTTPDecodingError: Error, LocalizedError {
    case decodingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .decodingFailed(let message):
            return "Decoding failed: \(message)"
        }
    }
}

struct BotsiHTTPResponseWrapper {
    private let data: Data
    private let decoder: HTTPDecoderHelper
    
    init(data: Data) {
        self.decoder = HTTPDecoderHelper()
        self.data = data
    }
    
    /// Decodes response data into a custom Decodable type
    func decode<T: Decodable>() throws -> T {
        return try decoder.decode(T.self, from: data)
    }
}

