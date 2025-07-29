//
//  BotsiProductItemModel.swift
//  Botsi
//
//  Created by Konstantin on 12.07.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiProductItemModel: Decodable, Sendable {
    public let state: String
    public let offerState: String
    public let defaultText: BotsiProductItemTextBlock
    public let freeText: BotsiProductItemTextBlock
    public let paygText: BotsiProductItemTextBlock
    public let paufText: BotsiProductItemTextBlock
    public let defaultState: BotsiProductItemTextState?
    public let selectedState: BotsiProductItemTextState
    public let defaultStyle: BotsiStyleModel
    public let selectedStyle: BotsiStyleModel
    public let isBadge: Bool
    public let badge: BotsiProductItemBadge

    private enum CodingKeys: String, CodingKey {
        case state
        case offerState = "offer_state"
        case defaultText = "default_text"
        case freeText = "free_text"
        case paygText = "payg_text"
        case paufText = "pauf_text"
        case defaultState = "default_state"
        case selectedState = "selected_state"
        case defaultStyle = "default_style"
        case selectedStyle = "selected_style"
        case isBadge = "is_badge"
        case badge
    }
}

@available(iOS 15.0, *)
public struct BotsiProductItemTextBlock: Decodable, Sendable {
    public let text1: String
    public let text1Fallback: String
    public let text2: String
    public let text2Fallback: String
    public let text3: String
    public let text3Fallback: String
    public let text4: String
    public let text4Fallback: String

    private enum CodingKeys: String, CodingKey {
        case text1 = "text_1"
        case text1Fallback = "text_1_fallback"
        case text2 = "text_2"
        case text2Fallback = "text_2_fallback"
        case text3 = "text_3"
        case text3Fallback = "text_3_fallback"
        case text4 = "text_4"
        case text4Fallback = "text_4_fallback"
    }
}

@available(iOS 15.0, *)
public struct BotsiControlTextModel: Decodable, Sendable {
    public let font: BotsiFontModel
    public let size: String
    public let color: String?
    public let opacity: Int?
    public let selectedColor: String?
    public let selectedOpacity: Int?
}

@available(iOS 15.0, *)
public struct BotsiProductItemTextState: Decodable, Sendable {
    public let text1: BotsiControlTextModel
    public let text2: BotsiControlTextModel
    public let text3: BotsiControlTextModel
    public let text4: BotsiControlTextModel

    private enum CodingKeys: String, CodingKey {
        case text1 = "text_1"
        case text2 = "text_2"
        case text3 = "text_3"
        case text4 = "text_4"
    }
}

@available(iOS 15.0, *)
public struct BotsiProductItemBadge: Decodable, Sendable {
    public let badgeText: String
    public let badgeColor: String
    public let badgeOpacity: Int?
    public let badgeRadius: String
    public let badgeTextFont: BotsiFontModel
    public let badgeTextSize: String
    public let badgeTextColor: String
    public let badgeTextOpacity: Int?

    private enum CodingKeys: String, CodingKey {
        case badgeText = "badge_text"
        case badgeColor = "badge_color"
        case badgeOpacity = "badge_opacity"
        case badgeRadius = "badge_radius"
        case badgeTextFont = "badge_text_font"
        case badgeTextSize = "badge_text_size"
        case badgeTextColor = "badge_text_color"
        case badgeTextOpacity = "badge_text_opacity"
    }
}
