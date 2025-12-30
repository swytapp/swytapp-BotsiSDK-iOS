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
    public let tabFont: BotsiLayoutModel.DefaultFont?
    public let customTabFont: BotsiCustomFont?
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        containerStyle = try container.decode(BotsiStyleModel.self, forKey: .containerStyle)
        activeTabStyle = try container.decode(BotsiTabStyleModel.self, forKey: .activeTabStyle)
        inactiveTabStyle = try container.decode(BotsiTabStyleModel.self, forKey: .inactiveTabStyle)
        selectedTab = try container.decode(String.self, forKey: .selectedTab)
        textSize = try container.decode(String.self, forKey: .textSize)
        padding = try container.decode(BotsiEdge.self, forKey: .padding)
        verticalOffset = try container.decode(String.self, forKey: .verticalOffset)
        
        if let defaultFont = try? container.decode(BotsiLayoutModel.DefaultFont.self, forKey: .tabFont) {
            self.tabFont = defaultFont
            self.customTabFont = nil
        } else if let customFont = try? container.decode(BotsiCustomFont.self, forKey: .tabFont) {
            self.tabFont = nil
            self.customTabFont = customFont
        } else {
            self.tabFont = nil
            self.customTabFont = nil
        }
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
