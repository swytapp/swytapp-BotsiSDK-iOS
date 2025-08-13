//
//  BotsiProfile+CustomEntry.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//

extension BotsiProfile {
    public struct BotsiCustomEntry: Sendable, Hashable, Codable {
        public let key: String
        public let value: String
        public let id: String
        
        public init(key: String, value: String, id: String) {
            self.key = key
            self.value = value
            self.id = id
        }
    }
}
