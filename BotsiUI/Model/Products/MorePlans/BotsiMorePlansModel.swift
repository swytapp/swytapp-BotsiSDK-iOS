//
//  BotsiMorePlandsModel.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 08.10.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiMorePlansModel: Decodable, Sendable {
    public let padding: BotsiEdge
    public let verticalOffset: String
    public let contentLayout: BotsiContentLayout

    private enum CodingKeys: String, CodingKey {
        case padding
        case verticalOffset = "vertical_offset"
        case contentLayout = "content_layout"
    }
}
