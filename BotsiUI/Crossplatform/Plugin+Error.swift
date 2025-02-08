//
//  File.swift
//  Botsi
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Botsi
import Foundation

package extension BotsiUI {
    enum PluginError: Error {
        case viewNotFound(String)
        case viewAlreadyPresented(String)
        case viewPresentationError(String)
        case delegateIsNotRegestired
    }
}

extension BotsiUI.PluginError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .viewNotFound(viewId): "BotsiUIError.viewNotFound(\(viewId))"
        case let .viewAlreadyPresented(viewId): "BotsiUIError.viewAlreadyPresented(\(viewId))"
        case let .viewPresentationError(viewId): "BotsiUIError.viewPresentationError(\(viewId))"
        case .delegateIsNotRegestired: "BotsiUIError.delegateIsNotRegestired"
        }
    }
}

extension BotsiUI.PluginError: CustomBotsiError {
    public static let errorDomain = BotsiError.BotsiUIErrorDomain

    public var originalError: Error? { nil }

    public var botsiErrorCode: BotsiError.ErrorCode {
        switch self {
        case .viewNotFound: return BotsiError.ErrorCode.wrongParam
        case .viewAlreadyPresented: return BotsiError.ErrorCode.wrongParam
        case .viewPresentationError: return BotsiError.ErrorCode.wrongParam
        case .delegateIsNotRegestired: return BotsiError.ErrorCode.unknown
        }
    }

    public var errorCode: Int { botsiErrorCode.rawValue }

    public var errorUserInfo: [String: Any] {
        var data: [String: Any] = [
            BotsiError.UserInfoKey.description: debugDescription,
        ]

        if let originalError = originalError {
            data[NSUnderlyingErrorKey] = originalError as NSError
        }
        return data
    }

    public var description: String {
        switch self {
        case let .viewNotFound(viewId): "BotsiUIError.viewNotFound(\(viewId))"
        case let .viewAlreadyPresented(viewId): "BotsiUIError.viewAlreadyPresented(\(viewId))"
        case let .viewPresentationError(viewId): "BotsiUIError.viewPresentationError(\(viewId))"
        case .delegateIsNotRegestired: "BotsiUIError.delegateIsNotRegestired"
        }
    }
}
