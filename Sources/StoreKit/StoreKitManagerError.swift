//
//  StoreKitManagerError.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

enum StoreKitManagerError: Error {
    case interrupted(BotsiError.Source)
    case noProductIDsFound(BotsiError.Source)
    case receiptIsEmpty(BotsiError.Source, error: Error?)
    case refreshReceiptFailed(BotsiError.Source, error: Error)
    case requestSKProductsFailed(BotsiError.Source, error: Error)
    case productPurchaseFailed(BotsiError.Source, transactionError: Error?)
    case trunsactionUnverified(BotsiError.Source, error: Error?)
    case invalidOffer(BotsiError.Source, error: String)
    case getSubscriptionInfoStatusFailed(BotsiError.Source, error: Error)
}

extension StoreKitManagerError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .interrupted(source):
            "StoreKitManagerError.interrupted(\(source))"
        case let .noProductIDsFound(source):
            "StoreKitManagerError.noProductIDsFound(\(source))"
        case let .receiptIsEmpty(source, error):
            if let error {
                "StoreKitManagerError.receiptIsEmpty(\(source), \(error)"
            } else {
                "StoreKitManagerError.receiptIsEmpty(\(source))"
            }
        case let .refreshReceiptFailed(source, error):
            "StoreKitManagerError.refreshReceiptFailed(\(source), \(error)"
        case let .requestSKProductsFailed(source, error):
            "StoreKitManagerError.requestSK1ProductsFailed(\(source), \(error)"
        case let .productPurchaseFailed(source, error):
            if let error {
                "StoreKitManagerError.productPurchaseFailed(\(source), \(error))"
            } else {
                "StoreKitManagerError.productPurchaseFailed(\(source))"
            }
        case let .trunsactionUnverified(source, error):
            if let error {
                "StoreKitManagerError.trunsactionUnverified(\(source), \(error))"
            } else {
                "StoreKitManagerError.trunsactionUnverified(\(source))"
            }
        case let .invalidOffer(source, error):
            "StoreKitManagerError.invalidOffer(\(source), \"\(error)\")"
        case let .getSubscriptionInfoStatusFailed(source, error):
            "StoreKitManagerError.getSubscriptionInfoStatusFailed(\(source), \(error))"
        }
    }
}

extension StoreKitManagerError {
    var source: BotsiError.Source {
        switch self {
        case let .productPurchaseFailed(src, _),
             let .noProductIDsFound(src),
             let .receiptIsEmpty(src, _),
             let .refreshReceiptFailed(src, _),
             let .requestSKProductsFailed(src, _),
             let .interrupted(src),
             let .trunsactionUnverified(src, _),
             let .invalidOffer(src, _),
             let .getSubscriptionInfoStatusFailed(src, _): src
        }
    }

    var originalError: Error? {
        switch self {
        case let .receiptIsEmpty(_, error),
             let .productPurchaseFailed(_, error),
             let .trunsactionUnverified(_, error): error
        case let .refreshReceiptFailed(_, error),
             let .getSubscriptionInfoStatusFailed(_, error),
             let .requestSKProductsFailed(_, error): error
        default: nil
        }
    }

    var skError: SKError? {
        guard let originalError else { return nil }
        return originalError as? SKError
    }
}

extension StoreKitManagerError {
    static func noProductIDsFound(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .noProductIDsFound(BotsiError.Source(file: file, function: function, line: line))
    }

    static func productPurchaseFailed(
        _ error: Error?,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .productPurchaseFailed(BotsiError.Source(file: file, function: function, line: line), transactionError: error)
    }

    static func receiptIsEmpty(
        _ error: Error? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .receiptIsEmpty(BotsiError.Source(file: file, function: function, line: line), error: error)
    }

    static func refreshReceiptFailed(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .refreshReceiptFailed(BotsiError.Source(file: file, function: function, line: line), error: error)
    }

    static func requestSK1ProductsFailed(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .requestSKProductsFailed(BotsiError.Source(file: file, function: function, line: line), error: error)
    }

    static func requestSK2ProductsFailed(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .requestSKProductsFailed(BotsiError.Source(file: file, function: function, line: line), error: error)
    }

    static func requestSK2IsEligibleForIntroOfferFailed(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .requestSKProductsFailed(BotsiError.Source(file: file, function: function, line: line), error: error)
    }

    static func interrupted(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .interrupted(BotsiError.Source(file: file, function: function, line: line))
    }

    static func trunsactionUnverified(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .trunsactionUnverified(BotsiError.Source(file: file, function: function, line: line), error: error)
    }

    static func invalidOffer(
        _ error: String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .invalidOffer(BotsiError.Source(file: file, function: function, line: line), error: error)
    }

    static func getSubscriptionInfoStatusFailed(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .getSubscriptionInfoStatusFailed(BotsiError.Source(file: file, function: function, line: line), error: error)
    }
}
