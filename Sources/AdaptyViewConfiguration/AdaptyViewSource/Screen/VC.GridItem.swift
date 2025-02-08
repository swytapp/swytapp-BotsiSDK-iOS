//
//  VC.GridItem.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension BotsiViewSource {
    struct GridItem: Sendable, Hashable {
        let length: BotsiViewConfiguration.GridItem.Length
        let horizontalAlignment: BotsiViewConfiguration.HorizontalAlignment
        let verticalAlignment: BotsiViewConfiguration.VerticalAlignment
        let content: BotsiViewSource.Element
    }
}

extension BotsiViewSource.Localizer {
    func gridItem(_ from: BotsiViewSource.GridItem) throws -> BotsiViewConfiguration.GridItem {
        try .init(
            length: from.length,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            content: element(from.content)
        )
    }
}

extension BotsiViewSource.GridItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case fixed
        case weight
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let length: BotsiViewConfiguration.GridItem.Length =
            if let value = try container.decodeIfPresent(Int.self, forKey: .weight) {
                .weight(value)
            } else {
                try .fixed(container.decode(BotsiViewConfiguration.Unit.self, forKey: .fixed))
            }

        try self.init(
            length: length,
            horizontalAlignment: container.decodeIfPresent(BotsiViewConfiguration.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? BotsiViewConfiguration.GridItem.defaultHorizontalAlignment,
            verticalAlignment: container.decodeIfPresent(BotsiViewConfiguration.VerticalAlignment.self, forKey: .verticalAlignment) ?? BotsiViewConfiguration.GridItem.defaultVerticalAlignment,
            content: container.decode(BotsiViewSource.Element.self, forKey: .content)
        )
    }
}
