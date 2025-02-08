//
//  InternalBotsiError.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 30.10.2022.
//

import Foundation
import StoreKit

enum InternalBotsiError: Error {
    case unknown(BotsiError.Source, String, error: Error)
    case activateOnceError(BotsiError.Source)
    case cantMakePayments(BotsiError.Source)
    case notActivated(BotsiError.Source)

    case profileWasChanged(BotsiError.Source)
    case profileCreateFailed(BotsiError.Source, error: HTTPError)
    case fetchFailed(BotsiError.Source, String, error: Error)
    case decodingFailed(BotsiError.Source, String, error: Error)

    case wrongParam(BotsiError.Source, String)
}

extension InternalBotsiError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .unknown(source, description, error: error):
            "BotsiError.unknown(\(source), \(description), \(error))"
        case let .activateOnceError(source):
            "BotsiError.activateOnceError(\(source))"
        case let .cantMakePayments(source):
            "BotsiError.cantMakePayments(\(source))"
        case let .notActivated(source):
            "BotsiError.notActivated(\(source))"
        case let .profileWasChanged(source):
            "BotsiError.profileWasChanged(\(source))"
        case let .profileCreateFailed(source, error):
            "BotsiError.profileCreateFailed(\(source), \(error))"
        case let .fetchFailed(source, description, error):
            "BotsiError.fetchFailed(\(source), \(description), \(error))"
        case let .decodingFailed(source, description, error):
            "BotsiError.decodingFailed(\(source), \(description), \(error))"
        case let .wrongParam(source, description):
            "BotsiError.wrongParam(\(source), \(description))"
        }
    }
}

extension InternalBotsiError {
    var source: BotsiError.Source {
        switch self {
        case let .unknown(src, _, _),
             let .activateOnceError(src),
             let .cantMakePayments(src),
             let .notActivated(src),
             let .profileWasChanged(src),
             let .profileCreateFailed(src, _),
             let .fetchFailed(src, _, _),
             let .decodingFailed(src, _, _),
             let .wrongParam(src, _):
            src
        }
    }

    var originalError: Error? {
        switch self {
        case let .profileCreateFailed(_, error):
            error
        case let .unknown(_, _, error),
             let .decodingFailed(_, _, error),
             let .fetchFailed(_, _, error):
            error
        default:
            nil
        }
    }
}

extension InternalBotsiError: CustomNSError {
    static let errorDomain = BotsiError.BotsiErrorDomain

    var botsiErrorCode: BotsiError.ErrorCode {
        switch self {
        case .unknown: .unknown
        case .activateOnceError: .activateOnceError
        case .cantMakePayments: .cantMakePayments
        case .notActivated: .notActivated
        case .profileWasChanged: .profileWasChanged
        case let .profileCreateFailed(_, error): error.botsiErrorCode
        case .fetchFailed: .networkFailed
        case .decodingFailed: .decodingFailed
        case .wrongParam: .wrongParam
        }
    }

    var errorCode: Int { botsiErrorCode.rawValue }

    var errorUserInfo: [String: Any] {
        var data: [String: Any] = [
            BotsiError.UserInfoKey.description: debugDescription,
            BotsiError.UserInfoKey.source: source.description,
        ]

        if let originalError {
            data[NSUnderlyingErrorKey] = originalError as NSError
        }
        return data
    }
}

extension BotsiError {
    static func activateOnceError(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalBotsiError.activateOnceError(BotsiError.Source(file: file, function: function, line: line)).asBotsiError
    }

    static func cantMakePayments(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalBotsiError.cantMakePayments(BotsiError.Source(file: file, function: function, line: line)).asBotsiError
    }

    static func notActivated(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalBotsiError.notActivated(BotsiError.Source(file: file, function: function, line: line)).asBotsiError
    }

    static func profileWasChanged(file: String = #fileID, function: String = #function, line: UInt = #line) -> Self {
        InternalBotsiError.profileWasChanged(BotsiError.Source(file: file, function: function, line: line)).asBotsiError
    }

    static func profileCreateFailed(
        _ error: HTTPError, file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        InternalBotsiError.profileCreateFailed(BotsiError.Source(file: file, function: function, line: line), error: error).asBotsiError
    }

    var isProfileCreateFailed: Bool {
        guard let error = wrapped as? InternalBotsiError else { return false }
        switch error {
        case .profileCreateFailed:
            return true
        default:
            return false
        }
    }

    static func decodingFallback(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.decodingFailed(BotsiError.Source(file: file, function: function, line: line), "Decoding Fallback Paywalls failed", error: error).asBotsiError
    }

    static func isNotFileUrl(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.wrongParam(
            BotsiError.Source(file: file, function: function, line: line), "Is not file URL"
        ).asBotsiError
    }

    static func wrongVersionFallback(
        _ text: String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.wrongParam(BotsiError.Source(file: file, function: function, line: line), text).asBotsiError
    }

    static func decodingSetVariationIdParams(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.decodingFailed(BotsiError.Source(file: file, function: function, line: line), "Decoding SetVariationIdParams failed", error: error).asBotsiError
    }

    static func decodingViewConfiguration(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.decodingFailed(BotsiError.Source(file: file, function: function, line: line), "Decoding ViewConfiguration failed", error: error).asBotsiError
    }

    static func decodingPaywallProduct(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.decodingFailed(BotsiError.Source(file: file, function: function, line: line), "Decoding BotsiPaywallProduct failed", error: error).asBotsiError
    }

    static func wrongParamPurchasedTransaction(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.wrongParam(BotsiError.Source(file: file, function: function, line: line), "Transaction is not in \"purchased\" state").asBotsiError
    }

    static func wrongParamOnboardingScreenOrder(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.wrongParam(BotsiError.Source(file: file, function: function, line: line), "Wrong screenOrder parameter value, it should be more than zero.").asBotsiError
    }

    static func wrongKeyOfCustomAttribute(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.wrongParam(BotsiError.Source(file: file, function: function, line: line), "The key must be string not more than 30 characters. Only letters, numbers, dashes, points and underscores allowed").asBotsiError
    }

    static func wrongStringValueOfCustomAttribute(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.wrongParam(BotsiError.Source(file: file, function: function, line: line), "The value must not be empty and not more than 50 characters.").asBotsiError
    }

    static func wrongCountCustomAttributes(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.wrongParam(BotsiError.Source(file: file, function: function, line: line), "The total number of custom attributes must be no more than 30").asBotsiError
    }

    static func wrongAttributeData(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.wrongParam(BotsiError.Source(file: file, function: function, line: line), error.localizedDescription).asBotsiError
    }

    static func fetchPaywallFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.fetchFailed(BotsiError.Source(file: file, function: function, line: line), "Fetch Profile failed", error: unknownError).asBotsiError
    }

    static func syncProfileFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.fetchFailed(BotsiError.Source(file: file, function: function, line: line), "Sync Profile failed", error: unknownError).asBotsiError
    }

    static func updateAttributionFaild(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.fetchFailed(BotsiError.Source(file: file, function: function, line: line), "Update Attribution failed", error: unknownError).asBotsiError
    }

    static func setIntegrationIdentifierFaild(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.fetchFailed(BotsiError.Source(file: file, function: function, line: line), "Set Integration Identifier failed", error: unknownError).asBotsiError
    }

    static func fetchViewConfigurationFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.fetchFailed(BotsiError.Source(file: file, function: function, line: line), "Fetch ViewConfiguration failed", error: unknownError).asBotsiError
    }

    static func trackEventFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        EventsError.encoding(unknownError, file: file, function: function, line: line).asBotsiError
    }

    static func decodingFallbackFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        decodingFallback(unknownError, file: file, function: function, line: line)
    }

    static func syncLastTransactionFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.fetchFailed(BotsiError.Source(file: file, function: function, line: line), "sync last transaction  failed", error: unknownError).asBotsiError
    }

    static func syncRecieptFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.fetchFailed(BotsiError.Source(file: file, function: function, line: line), "sync last transaction  failed", error: unknownError).asBotsiError
    }

    static func reportTransactionIdFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.fetchFailed(BotsiError.Source(file: file, function: function, line: line), "report transaction failed", error: unknownError).asBotsiError
    }

    static func validatePurchaseFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.fetchFailed(BotsiError.Source(file: file, function: function, line: line), "validate purchase failed", error: unknownError).asBotsiError
    }

    static func signSubscriptionOfferFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.fetchFailed(BotsiError.Source(file: file, function: function, line: line), "sign subscription offer failed", error: unknownError).asBotsiError
    }

    static func convertToBotsiErrorFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.unknown(BotsiError.Source(file: file, function: function, line: line), "Convert to BotsiError failed", error: unknownError).asBotsiError
    }

    static func fetchProductStatesFailed(
        unknownError: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.unknown(BotsiError.Source(file: file, function: function, line: line), "fetch product states failed", error: unknownError).asBotsiError
    }

    static func isNoViewConfigurationInPaywall(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        InternalBotsiError.wrongParam(BotsiError.Source(file: file, function: function, line: line), "BotsiPaywall.viewConfiguration is nil").asBotsiError
    }
}
