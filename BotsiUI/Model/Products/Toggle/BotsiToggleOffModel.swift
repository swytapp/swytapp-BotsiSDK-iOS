//
//  BotsiToggleOffModel.swift
//  Botsi
//
//  Created by Konstantin on 12.07.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiToggleOffModel: Decodable, Sendable {
    public let selectedProduct: String
    public let padding: String
    public let verticalOffset: String
    public let contentLayout: BotsiContentLayout

    private enum CodingKeys: String, CodingKey {
        case selectedProduct = "selected_product"
        case padding
        case verticalOffset = "vertical_offset"
        case contentLayout = "content_layout"
    }
}
