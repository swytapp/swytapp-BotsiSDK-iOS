//
//  BotsiPaywall+ViewConfiguration.swift.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 10.04.2024
//
//

import Foundation

extension BotsiPaywall {
    enum ViewConfiguration: Sendable, Hashable {
        case withoutData(BotsiLocale, botsiViewSource_id: String)
        case data(BotsiViewSource)

        var hasData: Bool {
            switch self {
            case .data: true
            default: false
            }
        }

        var responseLocale: BotsiLocale {
            switch self {
            case let .withoutData(value, _): value
            case let .data(data): data.responseLocale
            }
        }

        var id: String {
            switch self {
            case let .withoutData(_, value): value
            case let .data(data): data.id
            }
        }
    }
}

extension BotsiPaywall.ViewConfiguration: Codable {
    typealias CodingKeys = BotsiViewSource.ContainerCodingKeys

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self =
            if container.contains(.container) {
                try .data(BotsiViewSource(from: decoder))
            } else {
                try .withoutData(
                    container.decode(BotsiLocale.self, forKey: .responseLocale),
                    botsiViewSource_id: container.decode(String.self, forKey: .id)
                )
            }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(responseLocale, forKey: .responseLocale)
        try container.encode(id, forKey: .id)
    }
}
