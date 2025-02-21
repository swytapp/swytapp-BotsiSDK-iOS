//
//  BotsiNonSubscription.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//

import Foundation

extension BotsiProfile {
    public struct BotsiNonSubscription: Sendable, Hashable {
        public let isConsumable: Bool
        public let isOneTime: Bool
        public let isRefund: Bool
        public let purchasedAt: String
        public let purchasedId: String
        public let store: String
        public let sourceProductId: String
        public let transactionId: String
    }
}
