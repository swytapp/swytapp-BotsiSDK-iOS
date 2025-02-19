//
//  BotsiProfile+CustomEntry.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//

extension BotsiProfile {
    public struct BotsiCustomEntry: Sendable, Hashable {
        public let key: String
        public let value: String
        public let id: String
    }
}
