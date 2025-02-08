//
//  CustomBotsiError.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 27.01.2023
//

import StoreKit

package protocol CustomBotsiError: CustomStringConvertible, CustomDebugStringConvertible, CustomNSError {
    var originalError: Error? { get }
    var botsiErrorCode: BotsiError.ErrorCode { get }
}

extension CustomBotsiError {
    var asBotsiError: BotsiError {
        BotsiError(self)
    }
}

extension Error {
    var asBotsiError: BotsiError? {
        if let error = self as? BotsiError { return error }
        if let error = self as? CustomBotsiError { return BotsiError(error) }
        return nil
    }

    var unwrapped: Error {
        if let botsiError = self as? BotsiError {
            botsiError.wrapped
        } else {
            self
        }
    }
}

extension InternalBotsiError: CustomBotsiError {}

extension HTTPError: CustomBotsiError {
    static let errorDomain = BotsiError.HTTPErrorDomain

    var errorCode: Int { botsiErrorCode.rawValue }

    var errorUserInfo: [String: Any] {
        var data: [String: Any] = [
            BotsiError.UserInfoKey.description: debugDescription,
            BotsiError.UserInfoKey.source: source.description,
            BotsiError.UserInfoKey.endpoint: endpoint.description,
        ]
        if let statusCode {
            data[BotsiError.UserInfoKey.statusCode] = NSNumber(value: statusCode)
        }
        if let originalError {
            data[NSUnderlyingErrorKey] = originalError as NSError
        }
        return data
    }

    var botsiErrorCode: BotsiError.ErrorCode {
        if isCancelled { return .operationInterrupted }
        switch self {
        case .perform: return .encodingFailed
        case .network: return .networkFailed
        case .decoding: return .decodingFailed
        case let .backend(_, _, statusCode, _, _, _):
            return Backend.toBotsiErrorCode(statusCode: statusCode) ?? .networkFailed
        }
    }
}

extension EventsError: CustomBotsiError {
    static let errorDomain = BotsiError.EventsErrorDomain

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

    var botsiErrorCode: BotsiError.ErrorCode {
        switch self {
        case .sending: .networkFailed
        case .encoding: .encodingFailed
        case .decoding: .decodingFailed
        case .interrupted: .operationInterrupted
        }
    }
}

extension StoreKitManagerError: CustomBotsiError {
    static let errorDomain = BotsiError.SKManagerErrorDomain

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

    var botsiErrorCode: BotsiError.ErrorCode {
        if let code = convertErrorCode(skError) { return code }
        switch self {
        case .interrupted: return .operationInterrupted
        case .noProductIDsFound: return .noProductIDsFound
        case .receiptIsEmpty: return .cantReadReceipt
        case .refreshReceiptFailed: return .refreshReceiptFailed
        case .requestSKProductsFailed: return .productRequestFailed
        case .productPurchaseFailed: return .productPurchaseFailed
        case let .trunsactionUnverified(_, error):
            if let customError = error as? CustomBotsiError {
                return customError.botsiErrorCode
            } else {
                return .networkFailed
            }
        case .invalidOffer: return .invalidOfferIdentifier
        case .getSubscriptionInfoStatusFailed: return .fetchSubscriptionStatusFailed
        }
    }

    func convertErrorCode(_ error: SKError?) -> BotsiError.ErrorCode? {
        guard let error else { return nil }
        return BotsiError.ErrorCode(rawValue: error.code.rawValue)
    }
}
