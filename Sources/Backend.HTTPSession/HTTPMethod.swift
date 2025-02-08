//
//  HTTPMethod.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 21.09.2022.
//

import Foundation

enum HTTPMethod: String, Sendable, Hashable {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

extension HTTPMethod: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = HTTPMethod(rawValue: value.uppercased()) ?? .get
    }
}

extension HTTPMethod: CustomStringConvertible {
    var description: String { rawValue }
}
