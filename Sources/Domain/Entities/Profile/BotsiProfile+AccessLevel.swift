//
//  BotsiAccessLevel.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//
import Foundation

extension BotsiProfile {
    public struct BotsiAccessLevel: Sendable, Hashable, Codable {
        public let createdDate: String
        
        /// `identifier for the access level you set up in the Botsi Dashboard.`
        public let id: Int
        
        /// `Returns true if this access level is currently active. Typically, you can verify this property to assess whether a user has access to premium features.`
        public let isActive: Bool
        
        /// `An identifier for a product in the store that grants access to this level.`
        public let sourceProductId: String
        public let sourceBasePlanId: String?
        
        public let store: String
        
        /// `The timestamp indicating when this access level was activated.`
        public let activatedAt: String
        
        /// `Returns true if this access level is valid for a lifetime, meaning there is no expiration date.`
        public let isLifetime: Bool
        public let isRefund: Bool?
        
        /// `Returns true if this auto-renewable subscription is scheduled for renewal.`
        public let willRenew: Bool
        
        /// `Returns true if this auto-renewable subscription is currently within the grace period.`
        public let isInGracePeriod: Bool
        
        /// `The reason for the cancellation of the subscription.`
        public let cancellationReason: String?
        
        /// `An id of active offer in case the purchase was made with Android.`
        public let offerId: String?
        
        /// `The timestamp indicating when this access level begins, which may be set in the future.`
        public let startsAt: Date
        
        /// `The timestamp for when the access level was renewed. It may be nil if this was the initial purchase in the chain or if it is a non-renewing subscription or a non-consumable item (e.g., lifetime access).`
        public let renewedAt: Date
        
        /// `The timestamp that shows when the access level is set to expire. This could either be a past date or nil if the access is for a lifetime.`
        public let expiresAt: Date
        
        /// `The type of an active introductory offer. If this value is not nil, it indicates that the offer was utilized during the current subscription period.`
        public let activeIntroductoryOfferType: String?
        public let activePromotionalOfferType: String?
        public let activePromotionalOfferId: String?
        
        /// `The timestamp indicating when the auto-renewable subscription was canceled. The subscription may still be active; this simply means that auto-renewal has been disabled. It will be set to nil if the user reactivates the subscription.`
        public let unsubscribedAt: String?
        public let billingIssueDetectedAt: String?
        
        private enum CodingKeys: String, CodingKey {
            case createdDate, id, isActive, sourceProductId, sourceBasePlanId, store, activatedAt
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
            sourceBasePlanId = try container.decodeIfPresent(String.self, forKey: .sourceBasePlanId)
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
            try container.encodeIfPresent(sourceBasePlanId, forKey: .sourceBasePlanId)
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
