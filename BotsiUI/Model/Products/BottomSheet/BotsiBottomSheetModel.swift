//
//  BotsiBottomSheetModel.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 09.10.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiBottomSheetModel: Decodable, Sendable {
    public let padding: BotsiEdge
    public let verticalOffset: String
    public let contentLayout: BotsiContentLayout
    public let sheetStyle: BotsiStyleModel
    public let closeButtonStyle: BotsiStyleModel
    public let purchaseButton: BotsiSheetPurchaseButtonModel
    public let iconColor: BotsiFillColor
    public let iconSize: String
    public let titleText: String
    public let secondaryText: String
    public let titleTextStyle: BotsiTextStyleModel
    public let secondaryTextStyle: BotsiTextStyleModel

    private enum CodingKeys: String, CodingKey {
        case padding
        case verticalOffset = "vertical_offset"
        case contentLayout = "content_layout"
        case sheetStyle = "plans_styles"
        case closeButtonStyle = "close_button_styles"
        case purchaseButton = "purchase_button"
        case iconColor = "icon_color"
        case iconSize = "icon_size"
        case titleText = "title_text"
        case secondaryText = "secondary_text"
        case titleTextStyle = "title_text_style"
        case secondaryTextStyle = "secondary_text_style"
    }
}

@available(iOS 15.0, *)
public struct BotsiSheetPurchaseButtonModel: Decodable, Sendable {
    public let style: BotsiStyleModel
    public let text: String
    public let padding: BotsiEdge
    public let verticalOffset: String
    public let contentPadding: BotsiEdge
    public let align: BotsiAlign
    public let textStyle: BotsiTextStyleModel

    private enum CodingKeys: String, CodingKey {
        case style = "styles"
        case text = "button_text"
        case padding = "margin"
        case verticalOffset = "vertical_offset"
        case contentPadding = "padding"
        case align
        case textStyle = "button_text_style"
    }
}

