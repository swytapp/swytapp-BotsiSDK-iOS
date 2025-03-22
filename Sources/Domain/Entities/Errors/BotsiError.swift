//
//  BotsiError.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import Foundation

// MARK: - Botsi error protocol
protocol BotsiErrorConformable {
    var localizedDescription: String { get }
}

// MARK: - Botsi enum
public enum BotsiError: Error, Sendable, BotsiErrorConformable {
    /// `user errors`
    case userCreationFailed
    case userProfileNotFound
    case userGetProfileFailed
    
    case fetchingProductIdsFailed
    
    case invalidProductIdentifier(String)
    case purchaseFailed(String)
    case paymentNotAllowed
    case userCancelled
    case unknownError(Error)
    case networkError(String)
    case receiptValidationFailed(String)
    case sdkNotActivated
    
    case transactionFailed
    case restoreFailed
    
    case getPaywallFailed
    
    /// `wildcard`
    case customError(String, String)

    /// `error localized description`
    public var localizedDescription: String {
        switch self {
        case .userCreationFailed:
            return "User creation failed."
        case .userProfileNotFound:
            return "User profile not found."
        case .transactionFailed:
            return "Transaction failed."
        case .invalidProductIdentifier(let identifier):
            return "Invalid product identifier: \(identifier)"
        case .purchaseFailed(let reason):
            return "Purchase failed: \(reason)"
        case .paymentNotAllowed:
            return "Payment is not allowed on this device."
        case .userCancelled:
            return "User cancelled the purchase."
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .receiptValidationFailed(let message):
            return "Receipt validation failed: \(message)"
        case .customError(let title, let message):
            return "\(title): \(message)"
        case .sdkNotActivated:
            return "Unable to activate SDK"
        case .restoreFailed:
            return "Restore failed"
        case .fetchingProductIdsFailed:
            return "Fetching product ids failed"
        case .userGetProfileFailed:
            return "Get request for user profile failed"
        case .getPaywallFailed:
            return "Get request for user paywall with placement id failed"
        }
    }
}

// MARK: - Botsi Error Builder
public struct BotsiErrorBuilder {
    private var title: String?
    private var message: String?
    
    public init() {}
    
    public func withTitle(_ title: String) -> BotsiErrorBuilder {
        var builder = self
        builder.title = title
        return builder
    }
    
    public func withMessage(_ message: String) -> BotsiErrorBuilder {
        var builder = self
        builder.message = message
        return builder
    }
    
    public func build() -> BotsiError {
        let errorTitle = title ?? "Error"
        let errorMessage = message ?? "An unexpected error occurred."
        return .customError(errorTitle, errorMessage)
    }
}
