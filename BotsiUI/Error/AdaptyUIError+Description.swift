//
//  BotsiUIError+Description.swift
//
//
//  Created by Aleksei Valiano on 27.01.2023
//
//

import Foundation

extension BotsiUIError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .platformNotSupported: return "This platfrom is not supported by BotsiUI SDK"
        case .botsiNotActivated: return "You should activate Botsi SDK before using BotsiUI"
        case .botsiUINotActivated: return "You should activate BotsiUI SDK before using methods"
        case .activateOnce: return "You should activate BotsiUI SDK only once"
        case let .unsupportedTemplate(description): return description
        case let .styleNotFound(description): return description
        case let .wrongComponentType(description): return description
        case let .componentNotFound(description): return description
        case let .encoding(error), let .rendering(error): return error.localizedDescription
        }
    }
}
