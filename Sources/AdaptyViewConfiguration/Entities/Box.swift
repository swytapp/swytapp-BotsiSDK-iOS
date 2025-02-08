//
//  Box.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension BotsiViewConfiguration {
    package struct Box: Sendable, Hashable {
        static let defaultHorizontalAlignment: HorizontalAlignment = .center
        static let defaultVerticalAlignment: VerticalAlignment = .center

        package let width: Length?
        package let height: Length?
        package let horizontalAlignment: HorizontalAlignment
        package let verticalAlignment: VerticalAlignment
        package let content: Element?
    }
}

extension BotsiViewConfiguration.Box {
    package enum Length: Sendable {
        case fixed(BotsiViewConfiguration.Unit)
        case min(BotsiViewConfiguration.Unit)
        case shrink(BotsiViewConfiguration.Unit)
        case fillMax
    }
}

extension BotsiViewConfiguration.Box.Length: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .fixed(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .min(value):
            hasher.combine(2)
            hasher.combine(value)
        case let .shrink(value):
            hasher.combine(3)
            hasher.combine(value)
        case .fillMax:
            hasher.combine(4)
        }
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.Box {
        static func create(
            width: Length? = nil,
            height: Length? = nil,
            horizontalAlignment: BotsiViewConfiguration.HorizontalAlignment = defaultHorizontalAlignment,
            verticalAlignment: BotsiViewConfiguration.VerticalAlignment = defaultVerticalAlignment,
            content: BotsiViewConfiguration.Element? = nil
        ) -> Self {
            .init(
                width: width,
                height: height,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
                content: content
            )
        }
    }
#endif
