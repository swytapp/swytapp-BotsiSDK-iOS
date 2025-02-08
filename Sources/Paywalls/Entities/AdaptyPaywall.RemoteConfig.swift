//
//  BotsiPaywall.RemoteConfig.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 06.04.2024
//
//

import Foundation

extension BotsiPaywall {
    public struct RemoteConfig: Sendable {
        let botsiLocale: BotsiLocale

        public var locale: String { botsiLocale.id }
        /// A custom JSON string configured in Botsi Dashboard for this paywall.
        public let jsonString: String
        /// A custom dictionary configured in Botsi Dashboard for this paywall (same as `jsonString`)
        public var dictionary: [String: Any]? {
            guard let data = jsonString.data(using: .utf8),
                  let remoteConfig = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else { return nil }
            return remoteConfig
        }
    }
}

extension BotsiPaywall.RemoteConfig: CustomStringConvertible {
    public var description: String {
        "(locale: \(locale), jsonString: \(jsonString))"
    }
}

extension BotsiPaywall.RemoteConfig: Codable {
    enum CodingKeys: String, CodingKey {
        case botsiLocale = "lang"
        case jsonString = "data"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        botsiLocale = try container.decode(BotsiLocale.self, forKey: .botsiLocale)
        jsonString = try container.decode(String.self, forKey: .jsonString)
    }
}
