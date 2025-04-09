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
        public let isRefund: Bool
        
        /// `Returns true if this auto-renewable subscription is scheduled for renewal.`
        public let willRenew: Bool
        
        /// `Returns true if this auto-renewable subscription is currently within the grace period.`
        public let isInGracePeriod: Bool
        
        /// `The reason for the cancellation of the subscription.`
        public let cancellationReason: String?
        
        /// `An id of active offer in case the purchase was made with Android.`
        public let offerId: String?
        
        /// `The timestamp indicating when this access level begins, which may be set in the future.`
        public let startsAt: String
        
        /// `The timestamp for when the access level was renewed. It may be nil if this was the initial purchase in the chain or if it is a non-renewing subscription or a non-consumable item (e.g., lifetime access).`
        public let renewedAt: String
        
        /// `The timestamp that shows when the access level is set to expire. This could either be a past date or nil if the access is for a lifetime.`
        public let expiresAt: String
        
        /// `The type of an active introductory offer. If this value is not nil, it indicates that the offer was utilized during the current subscription period.`
        public let activeIntroductoryOfferType: String?
        public let activePromotionalOfferType: String
        public let activePromotionalOfferId: String?
        
        /// `The timestamp indicating when the auto-renewable subscription was canceled. The subscription may still be active; this simply means that auto-renewal has been disabled. It will be set to nil if the user reactivates the subscription.`
        public let unsubscribedAt: String?
        public let billingIssueDetectedAt: String?
    }
}
