//
//  BotsiProductItemModel.swift
//  Botsi
//
//  Created by Konstantin on 12.07.2025.
//

import Foundation

@available(iOS 15.0, *)
public enum BotsiProductState: String, Decodable, Sendable {
    case `default` = "default"
    case selected = "selected"
}

@available(iOS 15.0, *)
public enum BotsiProductOfferState: String, Decodable, Sendable {
    case `default` = "default"
    case freeTrial = "free_trial"
    case payAsYouGo = "pay_as_you_go"
    case payUpFront = "pay_up_front"
}

@available(iOS 15.0, *)
public struct BotsiProductItemModel: Decodable, Sendable, Identifiable {
    
    public var productId: String?
    public let state: BotsiProductState
    public let offerState: BotsiProductOfferState
    public let defaultText: BotsiProductItemTextBlock
    public let freeText: BotsiProductItemTextBlock
    public let paygText: BotsiProductItemTextBlock
    public let paufText: BotsiProductItemTextBlock
    public let defaultState: BotsiProductItemTextState
    public let selectedState: BotsiProductItemTextState
    public let defaultStyle: BotsiStyleModel
    public let selectedStyle: BotsiStyleModel
    public let isBadge: Bool
    public let badge: BotsiProductItemBadge

    public var id: String {
        productId ?? UUID().uuidString
    }

    private enum CodingKeys: String, CodingKey {
        case productId
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
public struct BotsiProductItemTextState: Decodable, Sendable {
    public let text1: BotsiTextStyleModel
    public let text2: BotsiTextStyleModel
    public let text3: BotsiTextStyleModel
    public let text4: BotsiTextStyleModel

    private enum CodingKeys: String, CodingKey {
        case text1 = "text_1"
        case text2 = "text_2"
        case text3 = "text_3"
        case text4 = "text_4"
    }
}

@available(iOS 15.0, *)
public struct BotsiProductItemBadge: Decodable, Sendable, BotsiTextPropertiesProvider {
    public let badgeText: String
    public let badgeColor: BotsiFillColor
    public let badgeOpacity: Int?
    public let badgeRadius: String
    public let font: BotsiLayoutModel.DefaultFont?
    public let size: String?
    public let color: BotsiFillColor?
    public let badgeTextOpacity: Int?

    private enum CodingKeys: String, CodingKey {
        case badgeText = "badge_text"
        case badgeColor = "badge_color"
        case badgeOpacity = "badge_opacity"
        case badgeRadius = "badge_radius"
        case font = "badge_text_font"
        case size = "badge_text_size"
        case color = "badge_text_color"
        case badgeTextOpacity = "badge_text_opacity"
    }
}
