//
//  BotsiLocale.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 07.11.2023
//

import Foundation

struct BotsiLocale: Sendable {
    static let defaultPaywallLocale = BotsiLocale(id: "en")

    let id: String
    var languageCode: String {
        String(id.prefix { !["-", "_"].contains($0) })
    }

    init(id: String) {
        self.id = id
    }

    func equalLanguageCode(_ otherLanguageCode: String) -> Bool {
        languageCode.lowercased() == otherLanguageCode.lowercased()
    }

    func equalLanguageCode(_ otherLocale: BotsiLocale) -> Bool {
        equalLanguageCode(otherLocale.languageCode)
    }
}

extension BotsiLocale: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(id: value)
    }
}

extension BotsiLocale: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension BotsiLocale: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.init(id: value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
}
