//
//  Text.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 01.05.2024
//
//

import Foundation

extension BotsiViewConfiguration {
    package struct Text: Sendable, Hashable {
        static let `default` = BotsiViewConfiguration.Text(
            value: .text(.empty),
            horizontalAlign: .leading,
            maxRows: nil,
            overflowMode: []
        )

        package let value: Value
        package let horizontalAlign: HorizontalAlignment
        package let maxRows: Int?
        package let overflowMode: Set<OverflowMode>

        package enum Value: Sendable {
            case text(RichText)
            case productText(LazyLocalisedProductText)
            case selectedProductText(LazyLocalisedUnknownProductText)
        }
    }
}

extension BotsiViewConfiguration.Text.Value: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .productText(value):
            hasher.combine(2)
            hasher.combine(value)
        case let .selectedProductText(value):
            hasher.combine(3)
            hasher.combine(value)
        }
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.Text {
        static func create(
            text: [BotsiViewConfiguration.RichText.Item],
            horizontalAlign: BotsiViewConfiguration.HorizontalAlignment = `default`.horizontalAlign,
            maxRows: Int? = `default`.maxRows,
            overflowMode: Set<BotsiViewConfiguration.Text.OverflowMode> = `default`.overflowMode
        ) -> Self {
            .init(
                value: .text(.create(items: text)),
                horizontalAlign: horizontalAlign,
                maxRows: maxRows,
                overflowMode: overflowMode
            )
        }

        static func create(
            text: BotsiViewConfiguration.RichText,
            horizontalAlign: BotsiViewConfiguration.HorizontalAlignment = `default`.horizontalAlign,
            maxRows: Int? = `default`.maxRows,
            overflowMode: Set<BotsiViewConfiguration.Text.OverflowMode> = `default`.overflowMode
        ) -> Self {
            .init(
                value: .text(text),
                horizontalAlign: horizontalAlign,
                maxRows: maxRows,
                overflowMode: overflowMode
            )
        }

        static func create(
            value: BotsiViewConfiguration.Text.Value,
            horizontalAlign: BotsiViewConfiguration.HorizontalAlignment = `default`.horizontalAlign,
            maxRows: Int? = `default`.maxRows,
            overflowMode: Set<BotsiViewConfiguration.Text.OverflowMode> = `default`.overflowMode
        ) -> Self {
            .init(
                value: value,
                horizontalAlign: horizontalAlign,
                maxRows: maxRows,
                overflowMode: overflowMode
            )
        }
    }
#endif
