//
//  BotsiAccessLevel.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//
import Foundation

extension BotsiProfile {
    public struct BotsiAccessLevel: Sendable, Hashable {
        public let createdDate: String
        public let id: String // identifier for the access level you set up in the Botsi Dashboard.
        public let isActive: Bool // Returns true if this access level is currently active. Typically, you can verify this property to assess whether a user has access to premium features.
        
        // An identifier for a product in the store that grants access to this level.
        public let sourceProductId: String
        public let sourceBasePlanId: String
        
        public let store: String /// - `app_store`
        public let activatedAt: String // The timestamp indicating when this access level was activated.
        public let isLifetime: Bool // Returns true if this access level is valid for a lifetime, meaning there is no expiration date.
        public let isRefund: Bool
        public let willRenew: Bool // Returns true if this auto-renewable subscription is scheduled for renewal.
        public let isInGracePeriod: Bool  // Returns true if this auto-renewable subscription is currently within the grace period.
        public let cancellationReason: String // The reason for the cancellation of the subscription.
        public let offerId: String //  An id of active offer in case the purchase was made with Android.
        public let startsAt: String // Date. The timestamp indicating when this access level begins, which may be set in the future.
        public let renewedAt: String  // Date. The timestamp for when the access level was renewed. It may be nil if this was the initial purchase in the chain or if it is a non-renewing subscription or a non-consumable item (e.g., lifetime access).
        public let expiresAt: String // Date. The timestamp that shows when the access level is set to expire. This could either be a past date or nil if the access is for a lifetime.
        
        // The type of an active introductory offer. If this value is not nil, it indicates that the offer was utilized during the current subscription period.
        /// - `pay_up_front`, `free_trial`, `pay_as_you_go`
        public let activeIntroductoryOfferType: String
        public let activePromotionalOfferType: String
        public let activePromotionalOfferId: String
        public let unsubscribedAt: String // Date. The timestamp indicating when the auto-renewable subscription was canceled. The subscription may still be active; this simply means that auto-renewal has been disabled. It will be set to nil if the user reactivates the subscription.
        public let billingIssueDetectedAt: String
    }
}
