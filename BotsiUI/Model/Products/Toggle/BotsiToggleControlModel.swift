//
//  BotsiToggleControlContentModel.swift
//  Botsi
//
//  Created by Konstantin on 12.07.2025.
//

@available(iOS 15.0, *)
public struct BotsiToggleControlModel: Decodable, Sendable, BotsiPaddingProvider {
    public let toggleState: String
    public let toggleStyle: BotsiStyleModel
    public let toggleColor: String
    public let toggleOpacity: Int
    public let state: String
    public let activeState: BotsiToggleStateModel
    public let inactiveState: BotsiToggleStateModel
    public let padding: BotsiEdge
    public let verticalOffset: String
    public let contentLayout: BotsiContentLayout

    private enum CodingKeys: String, CodingKey {
        case toggleState = "toggle_state"
        case toggleStyle = "toggle_style"
        case toggleColor = "toggle_color"
        case toggleOpacity = "toggle_opacity"
        case state
        case activeState = "active_state"
        case inactiveState = "inactive_state"
        case padding
        case verticalOffset = "vertical_offset"
        case contentLayout = "content_layout"
    }
}

@available(iOS 15.0, *)
public struct BotsiToggleStateModel: Decodable, Sendable {
    public let text: String
    public let textFallback: String
    public let textStyle: BotsiTextStyleModel?
    public let secondaryText: String
    public let secondaryTextFallback: String
    public let secondaryTextStyle: BotsiTextStyleModel

    private enum CodingKeys: String, CodingKey {
        case text
        case textFallback = "text_fallback"
        case textStyle = "text_style"
        case secondaryText = "secondary_text"
        case secondaryTextFallback = "secondary_text_fallback"
        case secondaryTextStyle = "secondary_text_style"
    }
}
