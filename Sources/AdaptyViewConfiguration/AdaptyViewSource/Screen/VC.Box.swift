//
//  VC.Box.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension BotsiViewSource {
    struct Box: Sendable, Hashable {
        let width: BotsiViewConfiguration.Box.Length?
        let height: BotsiViewConfiguration.Box.Length?
        let horizontalAlignment: BotsiViewConfiguration.HorizontalAlignment
        let verticalAlignment: BotsiViewConfiguration.VerticalAlignment
        let content: BotsiViewSource.Element?
    }
}

extension BotsiViewSource.Localizer {
    func box(_ from: BotsiViewSource.Box) throws -> BotsiViewConfiguration.Box {
        try .init(
            width: from.width,
            height: from.height,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            content: from.content.map(element)
        )
    }
}

extension BotsiViewSource.Box: Decodable {
    enum CodingKeys: String, CodingKey {
        case width
        case height
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            width: try? container.decodeIfPresent(BotsiViewConfiguration.Box.Length.self, forKey: .width),
            height: try? container.decodeIfPresent(BotsiViewConfiguration.Box.Length.self, forKey: .height),
            horizontalAlignment: container.decodeIfPresent(BotsiViewConfiguration.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? BotsiViewConfiguration.Box.defaultHorizontalAlignment,
            verticalAlignment: container.decodeIfPresent(BotsiViewConfiguration.VerticalAlignment.self, forKey: .verticalAlignment) ?? BotsiViewConfiguration.Box.defaultVerticalAlignment,
            content: container.decodeIfPresent(BotsiViewSource.Element.self, forKey: .content)
        )
    }
}

extension BotsiViewConfiguration.Box.Length: Decodable {
    enum CodingKeys: String, CodingKey {
        case min
        case shrink
        case fillMax = "fill_max"
    }

    package init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(BotsiViewConfiguration.Unit.self) {
            self = .fixed(value)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let value = try container.decodeIfPresent(Bool.self, forKey: .fillMax), value {
                self = .fillMax
            } else if let value = try container.decodeIfPresent(BotsiViewConfiguration.Unit.self, forKey: .min) {
                self = .min(value)
            } else if let value = try container.decodeIfPresent(BotsiViewConfiguration.Unit.self, forKey: .shrink) {
                self = .shrink(value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "don't found fill_max:true or min"))
            }
        }
    }
}
