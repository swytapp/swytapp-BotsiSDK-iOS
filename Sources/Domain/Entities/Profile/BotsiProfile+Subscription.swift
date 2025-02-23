//
//  BotsiSubscription.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//

import Foundation

extension BotsiProfile {
    public struct BotsiSubscription: Sendable, Hashable, Codable {
        public let createdDate: String
        public let id: Int
        public let isActive: Bool
        public let sourceProductId: String
        public let store: String
        public let activatedAt: String
        public let isLifetime: Bool
        public let isRefund: Bool
        public let willRenew: Bool
        public let isInGracePeriod: Bool
        public let cancellationReason: String
        public let offerId: String
        public let startsAt: String
        public let renewedAt: String
        public let expiresAt: String
        public let activeIntroductoryOfferType: String
        public let activePromotionalOfferType: String
        public let activePromotionalOfferId: String
        public let unsubscribedAt: String
        public let billingIssueDetectedAt: String
    }
}
