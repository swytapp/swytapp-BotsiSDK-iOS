//
//  ColorGradient.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension BotsiViewConfiguration {
    package struct ColorGradient: Hashable, Sendable {
        package let kind: Kind
        package let start: Point
        package let end: Point
        package let items: [Item]
    }
}

extension BotsiViewConfiguration.ColorGradient {
    package struct Item: Hashable, Sendable {
        package let color: BotsiViewConfiguration.Color
        package let p: Double
    }

    package enum Kind {
        case linear
        case conic
        case radial
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.ColorGradient {
        static func create(
            kind: BotsiViewConfiguration.ColorGradient.Kind,
            start: BotsiViewConfiguration.Point,
            end: BotsiViewConfiguration.Point,
            items: [BotsiViewConfiguration.ColorGradient.Item]
        ) -> Self {
            .init(
                kind: kind,
                start: start,
                end: end,
                items: items
            )
        }
    }

    package extension BotsiViewConfiguration.ColorGradient.Item {
        static func create(
            color: BotsiViewConfiguration.Color,
            p: Double
        ) -> Self {
            .init(
                color: color,
                p: p
            )
        }
    }
#endif

extension BotsiViewConfiguration.ColorGradient: Decodable {
    static func assetType(_ type: String) -> Bool {
        ContentType(rawValue: type) != nil
    }

    private enum ContentType: String, Sendable {
        case colorLinearGradient = "linear-gradient"
        case colorRadialGradient = "radial-gradient"
        case colorConicGradient = "conic-gradient"
    }

    private struct Points: Codable {
        let x0: Double
        let y0: Double
        let x1: Double
        let y1: Double

        var start: BotsiViewConfiguration.Point {
            BotsiViewConfiguration.Point(x: x0, y: y0)
        }

        var end: BotsiViewConfiguration.Point {
            BotsiViewConfiguration.Point(x: x1, y: y1)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case points
        case items = "values"
        case type
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([Item].self, forKey: .items)
        let points = try container.decode(Points.self, forKey: .points)
        start = points.start
        end = points.end

        kind =
            switch try container.decode(String.self, forKey: .type) {
            case BotsiViewConfiguration.ColorGradient.ContentType.colorRadialGradient.rawValue:
                .radial
            case BotsiViewConfiguration.ColorGradient.ContentType.colorConicGradient.rawValue:
                .conic
            default:
                .linear
            }
    }
}

extension BotsiViewConfiguration.ColorGradient.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case color
        case p
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decode(BotsiViewConfiguration.Color.self, forKey: .color)
        p = try container.decode(Double.self, forKey: .p)
    }
}
