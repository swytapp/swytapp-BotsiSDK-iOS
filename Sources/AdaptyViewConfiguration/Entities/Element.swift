//
//  Element.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension BotsiViewConfiguration {
    package enum Element: Sendable {
        case space(Int)
        indirect case stack(BotsiViewConfiguration.Stack, Properties?)
        case text(BotsiViewConfiguration.Text, Properties?)
        case image(BotsiViewConfiguration.Image, Properties?)
        case video(BotsiViewConfiguration.VideoPlayer, Properties?)
        indirect case button(BotsiViewConfiguration.Button, Properties?)
        indirect case box(BotsiViewConfiguration.Box, Properties?)
        indirect case row(BotsiViewConfiguration.Row, Properties?)
        indirect case column(BotsiViewConfiguration.Column, Properties?)
        indirect case section(BotsiViewConfiguration.Section, Properties?)
        case toggle(BotsiViewConfiguration.Toggle, Properties?)
        case timer(BotsiViewConfiguration.Timer, Properties?)
        indirect case pager(BotsiViewConfiguration.Pager, Properties?)

        case unknown(String, Properties?)
    }
}

extension BotsiViewConfiguration.Element {
    package struct Properties: Sendable, Hashable {
        static let defaultPadding = BotsiViewConfiguration.EdgeInsets(same: .point(0))
        static let defaultOffset = BotsiViewConfiguration.Offset.zero
        static let defaultVisibility = false

        package let decorator: BotsiViewConfiguration.Decorator?
        package let padding: BotsiViewConfiguration.EdgeInsets
        package let offset: BotsiViewConfiguration.Offset

        package let visibility: Bool
        package let transitionIn: [BotsiViewConfiguration.Transition]
    }
}

extension BotsiViewConfiguration.Element: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .space(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .stack(value, properties):
            hasher.combine(2)
            hasher.combine(value)
            hasher.combine(properties)
        case let .text(value, properties):
            hasher.combine(3)
            hasher.combine(value)
            hasher.combine(properties)
        case let .image(value, properties):
            hasher.combine(4)
            hasher.combine(value)
            hasher.combine(properties)
        case let .video(value, properties):
            hasher.combine(value)
            hasher.combine(properties)
        case let .button(value, properties):
            hasher.combine(5)
            hasher.combine(value)
            hasher.combine(properties)
        case let .box(value, properties):
            hasher.combine(6)
            hasher.combine(value)
            hasher.combine(properties)
        case let .row(value, properties):
            hasher.combine(7)
            hasher.combine(value)
            hasher.combine(properties)
        case let .column(value, properties):
            hasher.combine(8)
            hasher.combine(value)
            hasher.combine(properties)
        case let .section(value, properties):
            hasher.combine(9)
            hasher.combine(value)
            hasher.combine(properties)
        case let .toggle(value, properties):
            hasher.combine(10)
            hasher.combine(value)
            hasher.combine(properties)
        case let .timer(value, properties):
            hasher.combine(11)
            hasher.combine(value)
            hasher.combine(properties)
        case let .pager(value, properties):
            hasher.combine(12)
            hasher.combine(value)
            hasher.combine(properties)
        case let .unknown(value, properties):
            hasher.combine(13)
            hasher.combine(value)
            hasher.combine(properties)
        }
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.Element.Properties {
        static func create(
            decorator: BotsiViewConfiguration.Decorator? = nil,
            padding: BotsiViewConfiguration.EdgeInsets = BotsiViewConfiguration.Element.Properties.defaultPadding,
            offset: BotsiViewConfiguration.Offset = BotsiViewConfiguration.Element.Properties.defaultOffset,
            visibility: Bool = BotsiViewConfiguration.Element.Properties.defaultVisibility,
            transitionIn: [BotsiViewConfiguration.Transition] = []
        ) -> Self {
            .init(
                decorator: decorator,
                padding: padding,
                offset: offset,
                visibility: visibility,
                transitionIn: transitionIn
            )
        }
    }
#endif
