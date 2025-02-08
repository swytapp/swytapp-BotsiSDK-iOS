//
//  Point.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension BotsiViewConfiguration {
    package struct Point: Sendable, Hashable {
        package let x: Double
        package let y: Double
    }
}

extension BotsiViewConfiguration.Point {
    package static let zero = BotsiViewConfiguration.Point(x: 0.0, y: 0.0)
    package static let one = BotsiViewConfiguration.Point(x: 1.0, y: 1.0)

    package var isZero: Bool {
        x == 0.0 && y == 0.0
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.Point {
        static func create(
            x: Double = 0.0,
            y: Double = 0.0
        ) -> Self {
            .init(
                x: x,
                y: y
            )
        }
    }
#endif

extension BotsiViewConfiguration.Point: Decodable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self.init(x: 0.0, y: value)
        } else if let values = try? container.decode([Double].self) {
            switch values.count {
            case 0: self.init(x: 0.0, y: 0.0)
            case 1: self.init(x: 0.0, y: values[0])
            default: self.init(x: values[1], y: values[0])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                x: container.decodeIfPresent(Double.self, forKey: .x) ?? 0.0,
                y: container.decodeIfPresent(Double.self, forKey: .y) ?? 0.0
            )
        }
    }
}
