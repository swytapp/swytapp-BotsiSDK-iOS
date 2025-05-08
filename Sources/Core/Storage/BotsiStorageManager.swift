//
//  BotsiStorageManager.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//

import Foundation
import CryptoKit

enum BotsiStorageError: Error {
    case encodingFailed
    case decodingFailed
    case dataNotFound
    case integrityCheckFailed
}

public actor BotsiStorageManager {
    
    static let shared = BotsiStorageManager()
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    private func computeHash(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func save<T: Codable>(_ object: T, forKey key: String) throws {
        do {
            let data = try JSONEncoder().encode(object)
            let hash = computeHash(data)
            
            defaults.set(data, forKey: key)
            defaults.set(hash, forKey: key + "_hash")
            
        } catch {
            throw BotsiStorageError.encodingFailed
        }
    }
    
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = defaults.data(forKey: key),
              let storedHash = defaults.string(forKey: key + "_hash") else {
            return nil
        }
        
        let computedHash = computeHash(data)
        
        if computedHash != storedHash {
            throw BotsiStorageError.integrityCheckFailed
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw BotsiStorageError.decodingFailed
        }
    }
    
    func delete(forKey key: String) {
        defaults.removeObject(forKey: key)
        defaults.removeObject(forKey: key + "_hash")
    }
}

extension UserDefaults: @unchecked @retroactive Sendable {}
