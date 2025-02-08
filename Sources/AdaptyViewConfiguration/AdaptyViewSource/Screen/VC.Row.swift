//
//  VC.Row.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension BotsiViewSource {
    struct Row: Sendable, Hashable {
        let spacing: Double
        let items: [GridItem]
    }
}

extension BotsiViewSource.Localizer {
    func row(_ from: BotsiViewSource.Row) throws -> BotsiViewConfiguration.Row {
        try .init(
            spacing: from.spacing,
            items: from.items.map(gridItem)
        )
    }
}

extension BotsiViewSource.Row: Decodable {
    enum CodingKeys: String, CodingKey {
        case spacing
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([BotsiViewSource.GridItem].self, forKey: .items)
        )
    }
}
