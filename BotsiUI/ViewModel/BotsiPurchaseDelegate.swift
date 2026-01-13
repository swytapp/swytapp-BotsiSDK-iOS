//
//  BotsiPurchaseDelegate.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 13.01.2026.
//

import Foundation
import Botsi

/// Result type for purchase operations
@available(iOS 15.0, *)
public enum BotsiPurchaseResult: Sendable {
    /// Purchase completed successfully with updated profile
    case success(BotsiProfile)
    
    /// Purchase failed with error
    case failure(Error)
    
    /// Purchase was cancelled by the user
    case cancelled
}

/// Result type for restore operations
@available(iOS 15.0, *)
public enum BotsiRestoreResult: Sendable {
    /// Restore completed successfully with updated profile
    case success(BotsiProfile)
    
    /// Restore failed with error
    case failure(Error)
}

/// Protocol for handling custom purchase and restore logic.
///
/// Implement this protocol to override Botsi's default StoreKit purchase behavior
/// and use your own payment processor (e.g., RevenueCat, custom backend).
///
/// Example with RevenueCat:
/// ```swift
/// class RevenueCatPurchaseDelegate: BotsiPurchaseDelegate {
///     func handlePurchase(_ product: BotsiProduct) async -> BotsiPurchaseResult {
///         do {
///             // Purchase via RevenueCat
///             let offerings = try await Purchases.shared.offerings()
///             guard let package = offerings.current?.availablePackages.first(where: {
///                 $0.storeProduct.productIdentifier == product.productId
///             }) else {
///                 return .failure(PurchaseError.productNotFound)
///             }
///
///             let result = try await Purchases.shared.purchase(package: package)
///
///             // Sync to Botsi and get updated profile
///             let profile = try await Botsi.getProfile()
///             return .success(profile)
///         } catch {
///             return .failure(error)
///         }
///     }
///
///     func handleRestore() async -> BotsiRestoreResult {
///         do {
///             let customerInfo = try await Purchases.shared.restorePurchases()
///             let profile = try await Botsi.getProfile()
///             return .success(profile)
///         } catch {
///             return .failure(error)
///         }
///     }
/// }
/// ```
@available(iOS 15.0, *)
public protocol BotsiPurchaseDelegate: Sendable {
    
    /// Called when a purchase is initiated.
    ///
    /// Implement this method to handle purchases with your own payment processor.
    /// The Botsi SDK will call this method instead of its internal StoreKit purchase flow.
    ///
    /// - Parameter product: The product to purchase
    /// - Returns: A `BotsiPurchaseResult` indicating success, failure, or cancellation
    ///
    /// - Note: You should handle the entire purchase flow including:
    ///   - Payment processing
    ///   - Receipt validation
    ///   - Syncing purchase state to Botsi (if needed for analytics)
    ///   - Returning an updated `BotsiProfile`
    func handlePurchase(_ product: BotsiProduct) async -> BotsiPurchaseResult
    
    /// Called when restore purchases is initiated.
    ///
    /// Implement this method to handle purchase restoration with your own payment processor.
    /// The Botsi SDK will call this method instead of its internal StoreKit restore flow.
    ///
    /// - Returns: A `BotsiRestoreResult` indicating success or failure
    ///
    /// - Note: You should handle the entire restore flow including:
    ///   - Restoring purchases from your payment processor
    ///   - Syncing restored state to Botsi (if needed for analytics)
    ///   - Returning an updated `BotsiProfile`
    func handleRestore() async -> BotsiRestoreResult
}

// MARK: - Optional Methods

@available(iOS 15.0, *)
public extension BotsiPurchaseDelegate {
    
    /// Optional: Called before a purchase is initiated.
    /// Return `false` to prevent the purchase from proceeding.
    ///
    /// Use this for custom validation logic, e.g., checking user eligibility.
    func shouldPurchase(_ product: BotsiProduct) async -> Bool {
        return true
    }
    
    /// Optional: Called after a purchase completes successfully.
    /// Use this for custom analytics or post-purchase actions.
    func didCompletePurchase(_ product: BotsiProduct, profile: BotsiProfile) async {
        // Default: no-op
    }
    
    /// Optional: Called after restore completes successfully.
    /// Use this for custom analytics or post-restore actions.
    func didCompleteRestore(_ profile: BotsiProfile) async {
        // Default: no-op
    }
}
