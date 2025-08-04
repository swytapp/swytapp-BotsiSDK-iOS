//
//  BotsiProductsModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiProductsModel: Decodable, Sendable {
    public let grouping: BotsiProductGrouping
    public let selectedProduct: String
    public let state: String
    public let defaultStyle: BotsiStyleModel
    public let selectedStyle: BotsiStyleModel
    public let text1: BotsiTextStyleModel
    public let text2: BotsiTextStyleModel
    public let text3: BotsiTextStyleModel
    public let text4: BotsiTextStyleModel
    public let padding: BotsiEdge
    public let verticalOffset: String
    public let contentLayout: ProductContentLayoutModel

    enum CodingKeys: String, CodingKey {
        case grouping, state, padding
        case selectedProduct = "selected_product"
        case defaultStyle = "default_style"
        case selectedStyle = "selected_style"
        case text1 = "text_1"
        case text2 = "text_2"
        case text3 = "text_3"
        case text4 = "text_4"
        case verticalOffset = "vertical_offset"
        case contentLayout = "content_layout"
    }
}

@available(iOS 15.0, *)
public struct ProductContentLayoutModel: Decodable, Sendable {
    public let layout: BotsiLayout
    public let align: BotsiAlign
    public let padding: BotsiEdge
    public let spacing: String

    enum CodingKeys: String, CodingKey {
        case layout
        case align
        case padding
        case spacing
    }
}

@available(iOS 15.0, *)
public enum BotsiProductGrouping: String, Decodable, Sendable {
    case noSwitch = "no switch"       // No switch (all products are visible)
    case toggle = "Toggle"            // Toggle (for free trial and other offers)
    case tabs = "Tabs"                // Tabs (for comparing plan groups)
    case revealMore = "Buttons"       // Button that reveals more plans below
    case bottomSheet = "Bottom sheet" // Bottom sheet with more plans
    case unknown                      // fallback

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self).lowercased()

        self = BotsiProductGrouping(rawValue: raw) ?? .unknown
    }
}
