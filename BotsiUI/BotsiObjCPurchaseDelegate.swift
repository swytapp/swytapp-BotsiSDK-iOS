//
//  BotsiObjCPurchaseDelegate.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 13.01.2026.
//

import Foundation
import Botsi

// MARK: - Objective-C Purchase Delegate Protocol

/// Objective-C compatible protocol for handling custom purchase and restore logic.
///
/// Implement this protocol to override Botsi's default StoreKit purchase behavior
/// and use your own payment processor (e.g., RevenueCat, custom backend).
///
/// Example (Objective-C):
/// ```objc
/// @interface MyPurchaseDelegate : NSObject <BotsiObjCPurchaseDelegateProtocol>
/// @end
///
/// @implementation MyPurchaseDelegate
///
/// - (void)handlePurchase:(BotsiObjCProduct *)product
///            completion:(void (^)(BotsiObjCPurchaseResult *))completion {
///     // Your custom purchase logic
///     [RevenueCat purchaseProduct:product.productId completion:^(BOOL success, NSError *error) {
///         if (success) {
///             [BotsiObjCSDK getProfileWithCompletion:^(BotsiObjCProfile *profile, BotsiObjCError *error) {
///                 completion([[BotsiObjCPurchaseResult alloc] initWithSuccess:profile]);
///             }];
///         } else {
///             completion([[BotsiObjCPurchaseResult alloc] initWithFailure:error]);
///         }
///     }];
/// }
///
/// - (void)handleRestoreWithCompletion:(void (^)(BotsiObjCRestoreResult *))completion {
///     // Your custom restore logic
///     [RevenueCat restorePurchasesWithCompletion:^(BOOL success, NSError *error) {
///         if (success) {
///             [BotsiObjCSDK getProfileWithCompletion:^(BotsiObjCProfile *profile, BotsiObjCError *error) {
///                 completion([[BotsiObjCRestoreResult alloc] initWithSuccess:profile]);
///             }];
///         } else {
///             completion([[BotsiObjCRestoreResult alloc] initWithFailure:error]);
///         }
///     }];
/// }
///
/// @end
/// ```
@available(iOS 15.0, *)
@objc public protocol BotsiObjCPurchaseDelegateProtocol: NSObjectProtocol {
    
    /// Called when a purchase is initiated.
    ///
    /// Implement this method to handle purchases with your own payment processor.
    ///
    /// - Parameters:
    ///   - product: The product to purchase
    ///   - completion: Completion handler that must be called with the result
    @objc func handlePurchase(_ product: BotsiObjCProduct, completion: @escaping (BotsiObjCPurchaseResult) -> Void)
    
    /// Called when restore purchases is initiated.
    ///
    /// Implement this method to handle purchase restoration with your own payment processor.
    ///
    /// - Parameter completion: Completion handler that must be called with the result
    @objc func handleRestore(completion: @escaping (BotsiObjCRestoreResult) -> Void)
    
    // MARK: - Optional Methods
    
    /// Optional: Called before a purchase is initiated.
    /// Return NO to prevent the purchase from proceeding.
    @objc optional func shouldPurchase(_ product: BotsiObjCProduct) -> Bool
    
    /// Optional: Called after a purchase completes successfully.
    @objc optional func didCompletePurchase(_ product: BotsiObjCProduct, profile: BotsiObjCProfile)
    
    /// Optional: Called after restore completes successfully.
    @objc optional func didCompleteRestore(_ profile: BotsiObjCProfile)
}

// MARK: - Result Types

/// Result type for purchase operations in Objective-C.
@available(iOS 15.0, *)
@objc public class BotsiObjCPurchaseResult: NSObject {
    
    @objc public enum ResultType: Int {
        case success
        case failure
        case cancelled
    }
    
    @objc public let type: ResultType
    @objc public let profile: BotsiObjCProfile?
    @objc public let error: BotsiObjCError?
    
    private init(type: ResultType, profile: BotsiObjCProfile? = nil, error: BotsiObjCError? = nil) {
        self.type = type
        self.profile = profile
        self.error = error
        super.init()
    }
    
    /// Create a success result with profile
    @objc public convenience init(success profile: BotsiObjCProfile) {
        self.init(type: .success, profile: profile)
    }
    
    /// Create a failure result with error
    @objc public convenience init(failure error: NSError) {
        self.init(type: .failure, error: BotsiObjCError.fromSwift(swift: error))
    }
    
    /// Create a cancelled result
    @objc public convenience init(cancelled: Void) {
        self.init(type: .cancelled)
    }
    
    /// Convert from Swift BotsiPurchaseResult
    static func fromSwift(_ result: BotsiPurchaseResult) -> BotsiObjCPurchaseResult {
        switch result {
        case .success(let profile):
            return BotsiObjCPurchaseResult(success: BotsiObjCProfile.fromSwift(swift: profile))
        case .failure(let error):
            return BotsiObjCPurchaseResult(failure: error as NSError)
        case .cancelled:
            return BotsiObjCPurchaseResult(cancelled: ())
        }
    }
    
    /// Convert to Swift BotsiPurchaseResult
    func toSwift() -> BotsiPurchaseResult {
        switch type {
        case .success:
            return .success(profile!.toSwift())
        case .failure:
            return .failure(error!.toSwift())
        case .cancelled:
            return .cancelled
        }
    }
}

/// Result type for restore operations in Objective-C.
@available(iOS 15.0, *)
@objc public class BotsiObjCRestoreResult: NSObject {
    
    @objc public enum ResultType: Int {
        case success
        case failure
    }
    
    @objc public let type: ResultType
    @objc public let profile: BotsiObjCProfile?
    @objc public let error: BotsiObjCError?
    
    private init(type: ResultType, profile: BotsiObjCProfile? = nil, error: BotsiObjCError? = nil) {
        self.type = type
        self.profile = profile
        self.error = error
        super.init()
    }
    
    /// Create a success result with profile
    @objc public convenience init(success profile: BotsiObjCProfile) {
        self.init(type: .success, profile: profile)
    }
    
    /// Create a failure result with error
    @objc public convenience init(failure error: NSError) {
        self.init(type: .failure, error: BotsiObjCError.fromSwift(swift: error))
    }
    
    /// Convert from Swift BotsiRestoreResult
    static func fromSwift(_ result: BotsiRestoreResult) -> BotsiObjCRestoreResult {
        switch result {
        case .success(let profile):
            return BotsiObjCRestoreResult(success: BotsiObjCProfile.fromSwift(swift: profile))
        case .failure(let error):
            return BotsiObjCRestoreResult(failure: error as NSError)
        }
    }
    
    /// Convert to Swift BotsiRestoreResult
    func toSwift() -> BotsiRestoreResult {
        switch type {
        case .success:
            return .success(profile!.toSwift())
        case .failure:
            return .failure(error!.toSwift())
        }
    }
}

// MARK: - Swift Wrapper for Objective-C Delegate

/// Internal wrapper that converts Objective-C delegate to Swift BotsiPurchaseDelegate
@available(iOS 15.0, *)
internal final class BotsiObjCPurchaseDelegateWrapper: BotsiPurchaseDelegate, @unchecked Sendable {
    
    private let objcDelegate: BotsiObjCPurchaseDelegateProtocol
    
    init(objcDelegate: BotsiObjCPurchaseDelegateProtocol) {
        self.objcDelegate = objcDelegate
    }
    
    func handlePurchase(_ product: BotsiProduct) async -> BotsiPurchaseResult {
        return await withCheckedContinuation { continuation in
            let objcProduct = BotsiObjCProduct.fromSwift(swift: product)
            
            objcDelegate.handlePurchase(objcProduct) { result in
                continuation.resume(returning: result.toSwift())
            }
        }
    }
    
    func handleRestore() async -> BotsiRestoreResult {
        return await withCheckedContinuation { continuation in
            objcDelegate.handleRestore { result in
                continuation.resume(returning: result.toSwift())
            }
        }
    }
    
    func shouldPurchase(_ product: BotsiProduct) async -> Bool {
        guard let shouldPurchase = objcDelegate.shouldPurchase else {
            return true // Default behavior if not implemented
        }
        
        let objcProduct = BotsiObjCProduct.fromSwift(swift: product)
        return shouldPurchase(objcProduct)
    }
    
    func didCompletePurchase(_ product: BotsiProduct, profile: BotsiProfile) async {
        guard let didCompletePurchase = objcDelegate.didCompletePurchase else {
            return // Default behavior if not implemented
        }
        
        let objcProduct = BotsiObjCProduct.fromSwift(swift: product)
        let objcProfile = BotsiObjCProfile.fromSwift(swift: profile)
        didCompletePurchase(objcProduct, objcProfile)
    }
    
    func didCompleteRestore(_ profile: BotsiProfile) async {
        guard let didCompleteRestore = objcDelegate.didCompleteRestore else {
            return // Default behavior if not implemented
        }
        
        let objcProfile = BotsiObjCProfile.fromSwift(swift: profile)
        didCompleteRestore(objcProfile)
    }
}
