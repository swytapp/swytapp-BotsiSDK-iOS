//
//  BotsiMoreButtonModel.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 08.10.2025.
//

import Foundation

@available(iOS 15.0, *)
public enum BotsiMoreButtonState: String, Decodable, Sendable {
    case `default` = "default"
    case morePlansShown = "more_plans_shown"
}


@available(iOS 15.0, *)
public struct BotsiMoreButtonModel: Decodable, Sendable {
    public let state: BotsiMoreButtonState
    public let defaultText: MoreButtonText
    public let moreText: MoreButtonText
    public let style: BotsiButtonStyle
    public let padding: BotsiEdge
    public let verticalOffset: String?
    public let contentLayout: BotsiContentLayout?
    
    private enum CodingKeys: String, CodingKey {
        case state
        case defaultText = "default_text"
        case moreText = "more_plans_shown_text"
        case style
        case padding = "margin"
        case verticalOffset = "vertical_offset"
        case contentLayout = "content_layout"
    }
}

@available(iOS 15.0, *)
public struct MoreButtonText: Decodable, Sendable {
        public let text: String
        public let textStyle: BotsiTextStyleModel?
        public let secondaryText: String
        public let secondaryTextStyle: BotsiTextStyleModel?
        
        private enum CodingKeys: String, CodingKey {
            case text
            case textStyle = "text_style"
            case secondaryText = "secondary_text"
            case secondaryTextStyle = "secondary_text_style"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            text = try container.decode(String.self, forKey: .text)
            textStyle = try container.decodeIfPresent(BotsiTextStyleModel.self, forKey: .textStyle)
            secondaryText = try container.decode(String.self, forKey: .secondaryText)
            secondaryTextStyle = try container.decodeIfPresent(BotsiTextStyleModel.self, forKey: .secondaryTextStyle)
        }
    }
