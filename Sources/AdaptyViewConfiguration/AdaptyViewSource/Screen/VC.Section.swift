//
//  VC.Section.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension BotsiViewSource {
    struct Section: Sendable, Hashable {
        let id: String
        let index: Int
        let content: [BotsiViewSource.Element]
    }
}

extension BotsiViewSource.Localizer {
    func section(_ from: BotsiViewSource.Section) throws -> BotsiViewConfiguration.Section {
        try .init(
            id: from.id,
            index: from.index,
            content: from.content.map(element)
        )
    }
}

extension BotsiViewSource.Section: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case index
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            id: container.decode(String.self, forKey: .id),
            index: container.decodeIfPresent(Int.self, forKey: .index) ?? 0,
            content: container.decode([BotsiViewSource.Element].self, forKey: .content)
        )
    }
}
