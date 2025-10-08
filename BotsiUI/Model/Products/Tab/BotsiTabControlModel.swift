//
//  BotsiTabControlModel.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 06.10.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiTabControlModel: Decodable, Sendable {
    public let containerStyle: BotsiStyleModel
    public let activeTabStyle: BotsiTabStyleModel
    public let inactiveTabStyle: BotsiTabStyleModel
    public let tabFont: BotsiLayoutModel.DefaultFont
    public let selectedTab: String
    public let textSize: String
    public let padding: BotsiEdge
    public let verticalOffset: String

    private enum CodingKeys: String, CodingKey {
        case containerStyle = "container_style"
        case activeTabStyle = "active_state"
        case inactiveTabStyle = "inactive_state"
        case textSize = "tab_text_size"
        case padding = "padding"
        case tabFont = "tab_text_font"
        case verticalOffset = "vertical_offset"
        case selectedTab = "selected_tab"
    }
}

@available(iOS 15.0, *)
public struct BotsiTabStyleModel: Decodable, Sendable {
    public let fontColor: BotsiFillColor
    public let padding: BotsiEdge
    public let style: BotsiStyleModel

    private enum CodingKeys: String, CodingKey {
        case fontColor = "font_color"
        case padding
        case style = "state_style"
    }
}
