//
//  VC.Localization.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension BotsiViewSource {
    struct Localization: Sendable, Hashable {
        let id: BotsiLocale
        let isRightToLeft: Bool?
        let strings: [String: Item]?
        let assets: [String: Asset]?

        struct Item: Sendable, Hashable  {
            let value: RichText
            let fallback: RichText?
        }
    }
}

extension BotsiViewSource.Localization: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case strings
        case assets
        case isRightToLeft = "is_right_to_left"
    }

    enum ItemCodingKeys: String, CodingKey {
        case id
        case value
        case fallback
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(BotsiLocale.self, forKey: .id)
        isRightToLeft = try container.decodeIfPresent(Bool.self, forKey: .isRightToLeft)

        assets = try (container.decodeIfPresent(BotsiViewSource.AssetsContainer.self, forKey: .assets))?.value

        var stringsContainer = try container.nestedUnkeyedContainer(forKey: .strings)
        var strings = [String: Item]()
        if let count = stringsContainer.count {
            strings.reserveCapacity(count)
        }
        while !stringsContainer.isAtEnd {
            let item = try stringsContainer.nestedContainer(keyedBy: ItemCodingKeys.self)
            try strings[item.decode(String.self, forKey: .id)] = try Item(
                value: item.decode(BotsiViewSource.RichText.self, forKey: .value),
                fallback: item.decodeIfPresent(BotsiViewSource.RichText.self, forKey: .fallback)
            )
        }
        self.strings = strings.isEmpty ? nil : strings
    }
}
