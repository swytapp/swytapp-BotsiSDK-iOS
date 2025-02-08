//
//  BotsiStorefront.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import Foundation

public struct BotsiStorefront: Sendable, Identifiable, Hashable {
    public let id: String
    public let countryCode: String
}

extension BotsiStorefront: CustomStringConvertible {
    public var description: String {
        "\(id) \(countryCode)"
    }
}

extension BotsiStorefront: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case countryCode = "country_code"
    }
}
