//
//  BotsiTabModel.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 06.10.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiTabModel: Decodable, Sendable {
    public let title: String
    public let padding: BotsiEdge
    public let verticalOffset: String
    public let contentLayout: BotsiContentLayout

    private enum CodingKeys: String, CodingKey {
        case title = "tab_title"
        case padding
        case verticalOffset = "vertical_offset"
        case contentLayout = "content_layout"
    }
}
