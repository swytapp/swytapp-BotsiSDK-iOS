//
//  BotsiProductsModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiProductsModel: Decodable, Sendable {
    public let grouping: String
    public let selectedProduct: String
    public let state: String
    public let defaultStyle: BotsiStyleModel
    public let selectedStyle: BotsiStyleModel
    public let text1: BotsiTextStyleModel
    public let text2: BotsiTextStyleModel
    public let text3: BotsiTextStyleModel
    public let text4: BotsiTextStyleModel
    public let padding: String
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
    public let layout: String
    public let align: String
    public let padding: String
    public let spacing: String

    enum CodingKeys: String, CodingKey {
        case layout
        case align
        case padding
        case spacing
    }
}

