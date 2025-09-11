//
//  KeyedDecodingContainer.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 08.09.2025.
//

import Foundation

extension KeyedDecodingContainer {
    func decodeCGFloat(forKey key: Key) throws -> CGFloat {
        if let doubleValue = try? decode(Double.self, forKey: key) {
            return CGFloat(doubleValue)
        }
        if let stringValue = try? decode(String.self, forKey: key),
           let doubleValue = Double(stringValue) {
            return CGFloat(doubleValue)
        }
        return 0
    }

    func decodeInt(forKey key: Key) throws -> Int {
        if let intValue = try? decode(Int.self, forKey: key) {
            return intValue
        }
        if let stringValue = try? decode(String.self, forKey: key),
           let intValue = Int(stringValue) {
            return intValue
        }
        return 0
    }
}
