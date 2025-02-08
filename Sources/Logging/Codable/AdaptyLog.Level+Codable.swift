//
//  BotsiLog.Level+Codable.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 22.08.2024
//

import Foundation

extension BotsiLog.Level: Codable {
    public init(from decoder: Decoder) throws {
        self = try Log.Level(stringLiteral: decoder.singleValueContainer().decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringLiteral)
    }
}
