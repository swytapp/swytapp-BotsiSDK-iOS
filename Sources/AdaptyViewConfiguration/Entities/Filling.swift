//
//  Filling.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension BotsiViewConfiguration {
    enum Filling: Sendable {
        static let `default` = Filling.solidColor(Color.black)

        case solidColor(BotsiViewConfiguration.Color)
        case colorGradient(BotsiViewConfiguration.ColorGradient)

        package var asSolidColor: BotsiViewConfiguration.Color? {
            switch self {
            case let .solidColor(value): value
            default: nil
            }
        }

        package var asColorGradient: BotsiViewConfiguration.ColorGradient {
            switch self {
            case let .solidColor(value):
                BotsiViewConfiguration.ColorGradient(
                    kind: .linear,
                    start: .zero,
                    end: .one,
                    items: [.init(color: value, p: 0.5)]
                )
            case let .colorGradient(value):
                value
            }
        }
    }
}

extension BotsiViewConfiguration.Filling: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .solidColor(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .colorGradient(value):
            hasher.combine(2)
            hasher.combine(value)
        }
    }
}

package extension BotsiViewConfiguration.Mode<BotsiViewConfiguration.Filling> {
    var hasColorGradient: Bool {
        switch self {
        case .same(.solidColor), .different(light: .solidColor, dark: .solidColor):
            false
        default:
            true
        }
    }

    var asSolidColor: BotsiViewConfiguration.Mode<BotsiViewConfiguration.Color>? {
        switch self {
        case let .same(.solidColor(value)):
            .same(value)
        case let .different(.solidColor(light), .solidColor(dark)):
            .different(light: light, dark: dark)
        default:
            nil
        }
    }

    var asColorGradient: BotsiViewConfiguration.Mode<BotsiViewConfiguration.ColorGradient> {
        switch self {
        case let .same(value):
            .same(value.asColorGradient)
        case let .different(light, dark):
            .different(light: light.asColorGradient, dark: dark.asColorGradient)
        }
    }
}

extension BotsiViewConfiguration.Filling: Decodable {
    static func assetType(_ type: String) -> Bool {
        type == BotsiViewConfiguration.Color.assetType || BotsiViewConfiguration.ColorGradient.assetType(type)
    }

    package init(from decoder: Decoder) throws {
        enum CodingKeys: String, CodingKey {
            case type
            case value
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(String.self, forKey: .type) {
        case BotsiViewConfiguration.Color.assetType:
            self = try .solidColor(container.decode(BotsiViewConfiguration.Color.self, forKey: .value))
        case let type where BotsiViewConfiguration.ColorGradient.assetType(type):
            self = try .colorGradient(BotsiViewConfiguration.ColorGradient(from: decoder))
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.type], debugDescription: "unknown color assset type"))
        }
    }
}
