//
//  BotsiUIError+CustomBotsiError.swift
//
//
//  Created by Aleksei Valiano on 27.01.2023
//
//

import Botsi
import Foundation

public extension BotsiError {
    static let BotsiUIErrorDomain = "BotsiUIErrorDomain"
}

extension BotsiUIError: CustomBotsiError {
    public static let errorDomain = BotsiError.BotsiUIErrorDomain

    public var originalError: Error? {
        switch self {
        case let .encoding(error), let .rendering(error):
            return error
        default:
            return nil
        }
    }

    public var botsiErrorCode: BotsiError.ErrorCode {
        switch self {
        case .platformNotSupported:
            return BotsiError.ErrorCode.unknown
        case .botsiNotActivated, .botsiUINotActivated:
            return BotsiError.ErrorCode.notActivated
        case .activateOnce:
            return BotsiError.ErrorCode.activateOnceError
        case .encoding:
            return BotsiError.ErrorCode.encodingFailed
        case .unsupportedTemplate:
            return BotsiError.ErrorCode.unsupportedData
        case .styleNotFound,
             .wrongComponentType,
             .componentNotFound,
             .rendering:
            return BotsiError.ErrorCode.decodingFailed
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
        case .platformNotSupported:
            "This platfrom is not supported by BotsiUI SDK"
        case .botsiNotActivated:
            "You should activate Botsi SDK before using BotsiUI"
        case .botsiUINotActivated:
            "You should activate BotsiUI SDK before using methods"
        case .activateOnce:
            "You should activate BotsiUI SDK only once"
        case let .encoding(error):
            "BotsiUIError.encoding(\(error.localizedDescription))"
        case let .unsupportedTemplate(description):
            "BotsiUIError.unsupportedTemplate(\(description))"
        case let .styleNotFound(description):
            "BotsiUIError.styleNotFound(\(description))"
        case let .wrongComponentType(description):
            "BotsiUIError.wrongComponentType(\(description))"
        case let .componentNotFound(description):
            "BotsiUIError.componentNotFound(\(description))"
        case let .rendering(error):
            "BotsiUIError.rendering(\(error.localizedDescription))"
        }
    }
}
