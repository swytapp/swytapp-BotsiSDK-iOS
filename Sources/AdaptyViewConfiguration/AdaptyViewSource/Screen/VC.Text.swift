//
//  VC.Text.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension BotsiViewSource {
    struct Text: Sendable, Hashable {
        let stringId: StringId
        let horizontalAlign: BotsiViewConfiguration.HorizontalAlignment
        let maxRows: Int?
        let overflowMode: Set<BotsiViewConfiguration.Text.OverflowMode>
        let defaultTextAttributes: TextAttributes?
    }
}

extension BotsiViewSource.Localizer {
    func text(_ textBlock: BotsiViewSource.Text) throws -> BotsiViewConfiguration.Text {
        let value: BotsiViewConfiguration.Text.Value =
            switch textBlock.stringId {
            case let .basic(stringId):
                .text(richText(
                    stringId: stringId,
                    defaultTextAttributes: textBlock.defaultTextAttributes
                ) ?? .empty)

            case let .product(info):
                if let botsiProductId = info.botsiProductId {
                    .productText(BotsiViewConfiguration.LazyLocalisedProductText(
                        botsiProductId: botsiProductId,
                        suffix: info.suffix,
                        localizer: self,
                        defaultTextAttributes: textBlock.defaultTextAttributes
                    ))
                } else {
                    .selectedProductText(BotsiViewConfiguration.LazyLocalisedUnknownProductText(
                        productGroupId: info.productGroupId ?? BotsiViewSource.StringId.Product.defaultProductGroupId,
                        suffix: info.suffix,
                        localizer: self,
                        defaultTextAttributes: textBlock.defaultTextAttributes
                    ))
                }
            }

        return BotsiViewConfiguration.Text(
            value: value,
            horizontalAlign: textBlock.horizontalAlign,
            maxRows: textBlock.maxRows,
            overflowMode: textBlock.overflowMode
        )
    }
}

extension BotsiViewSource.Text: Decodable {
    enum CodingKeys: String, CodingKey {
        case stringId = "string_id"
        case horizontalAlign = "align"
        case maxRows = "max_rows"
        case overflowMode = "on_overflow"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stringId = try container.decode(BotsiViewSource.StringId.self, forKey: .stringId)
        horizontalAlign = try container.decodeIfPresent(BotsiViewConfiguration.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        maxRows = try container.decodeIfPresent(Int.self, forKey: .maxRows)
        overflowMode =
            if let value = try? container.decode(BotsiViewConfiguration.Text.OverflowMode.self, forKey: .overflowMode) {
                Set([value])
            } else {
                try Set(container.decodeIfPresent([BotsiViewConfiguration.Text.OverflowMode].self, forKey: .overflowMode) ?? [])
            }
        let textAttributes = try BotsiViewSource.TextAttributes(from: decoder)
        defaultTextAttributes = textAttributes.isEmpty ? nil : textAttributes
    }
}
