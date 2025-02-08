//
//  GridItem.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.05.2024
//
//

import Foundation

extension BotsiViewConfiguration {
    package struct GridItem: Sendable, Hashable {
        static let defaultHorizontalAlignment: HorizontalAlignment = .center
        static let defaultVerticalAlignment: VerticalAlignment = .center

        package let length: Length
        package let horizontalAlignment: BotsiViewConfiguration.HorizontalAlignment
        package let verticalAlignment: BotsiViewConfiguration.VerticalAlignment
        package let content: BotsiViewConfiguration.Element
    }
}

extension BotsiViewConfiguration.GridItem {
    package enum Length: Sendable {
        case fixed(BotsiViewConfiguration.Unit)
        case weight(Int)
    }
}

extension BotsiViewConfiguration.GridItem.Length: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .fixed(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .weight(value):
            hasher.combine(2)
            hasher.combine(value)
        }
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.GridItem {
        static func create(
            length: Length,
            horizontalAlignment: BotsiViewConfiguration.HorizontalAlignment = defaultHorizontalAlignment,
            verticalAlignment: BotsiViewConfiguration.VerticalAlignment = defaultVerticalAlignment,
            content: BotsiViewConfiguration.Element
        ) -> Self {
            .init(
                length: length,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
                content: content
            )
        }
    }
#endif
