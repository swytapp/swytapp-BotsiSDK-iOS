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
        public let isRefund: Bool?
        public let willRenew: Bool
        public let isInGracePeriod: Bool
        public let cancellationReason: String?
        public let offerId: String?
        public let startsAt: Date
        public let renewedAt: Date
        public let expiresAt: Date
        public let activeIntroductoryOfferType: String?
        public let activePromotionalOfferType: String?
        public let activePromotionalOfferId: String?
        public let unsubscribedAt: String?
        public let billingIssueDetectedAt: String?
        
        private enum CodingKeys: String, CodingKey {
            case createdDate, id, isActive, sourceProductId, store, activatedAt
            case isLifetime, isRefund, willRenew, isInGracePeriod, cancellationReason, offerId
            case startsAt, renewedAt, expiresAt, activeIntroductoryOfferType, activePromotionalOfferType
            case activePromotionalOfferId, unsubscribedAt, billingIssueDetectedAt
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            createdDate = try container.decode(String.self, forKey: .createdDate)
            id = try container.decode(Int.self, forKey: .id)
            isActive = try container.decode(Bool.self, forKey: .isActive)
            sourceProductId = try container.decode(String.self, forKey: .sourceProductId)
            store = try container.decode(String.self, forKey: .store)
            activatedAt = try container.decode(String.self, forKey: .activatedAt)
            isLifetime = try container.decode(Bool.self, forKey: .isLifetime)
            isRefund = try container.decodeIfPresent(Bool.self, forKey: .isRefund)
            willRenew = try container.decode(Bool.self, forKey: .willRenew)
            isInGracePeriod = try container.decode(Bool.self, forKey: .isInGracePeriod)
            cancellationReason = try container.decodeIfPresent(String.self, forKey: .cancellationReason)
            offerId = try container.decodeIfPresent(String.self, forKey: .offerId)
            
            let startsAtString = try container.decode(String.self, forKey: .startsAt)
            startsAt = try Date.parseISO8601(from: startsAtString)
            let renewedAtString = try container.decode(String.self, forKey: .renewedAt)
            renewedAt = try Date.parseISO8601(from: renewedAtString)
            let expiresAtString = try container.decode(String.self, forKey: .expiresAt)
            expiresAt = try Date.parseISO8601(from: expiresAtString)
            
            activeIntroductoryOfferType = try container.decodeIfPresent(String.self, forKey: .activeIntroductoryOfferType)
            activePromotionalOfferType = try container.decodeIfPresent(String.self, forKey: .activePromotionalOfferType)
            activePromotionalOfferId = try container.decodeIfPresent(String.self, forKey: .activePromotionalOfferId)
            unsubscribedAt = try container.decodeIfPresent(String.self, forKey: .unsubscribedAt)
            billingIssueDetectedAt = try container.decodeIfPresent(String.self, forKey: .billingIssueDetectedAt)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(createdDate, forKey: .createdDate)
            try container.encode(id, forKey: .id)
            try container.encode(isActive, forKey: .isActive)
            try container.encode(sourceProductId, forKey: .sourceProductId)
            try container.encode(store, forKey: .store)
            try container.encode(activatedAt, forKey: .activatedAt)
            try container.encode(isLifetime, forKey: .isLifetime)
            try container.encodeIfPresent(isRefund, forKey: .isRefund)
            try container.encode(willRenew, forKey: .willRenew)
            try container.encode(isInGracePeriod, forKey: .isInGracePeriod)
            try container.encodeIfPresent(cancellationReason, forKey: .cancellationReason)
            try container.encodeIfPresent(offerId, forKey: .offerId)
            
            try container.encode(startsAt.toISO8601String(), forKey: .startsAt)
            try container.encode(renewedAt.toISO8601String(), forKey: .renewedAt)
            try container.encode(expiresAt.toISO8601String(), forKey: .expiresAt)
            
            try container.encodeIfPresent(activeIntroductoryOfferType, forKey: .activeIntroductoryOfferType)
            try container.encodeIfPresent(activePromotionalOfferType, forKey: .activePromotionalOfferType)
            try container.encodeIfPresent(activePromotionalOfferId, forKey: .activePromotionalOfferId)
            try container.encodeIfPresent(unsubscribedAt, forKey: .unsubscribedAt)
            try container.encodeIfPresent(billingIssueDetectedAt, forKey: .billingIssueDetectedAt)
        }
    }
}
