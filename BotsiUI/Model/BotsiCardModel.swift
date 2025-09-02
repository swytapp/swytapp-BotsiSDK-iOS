//
//  BotsiCardModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiCardModel: Decodable, Sendable, BotsiPaddingProvider {
    
    public let style: BotsiStyleModel
    public let backgroundImage: String?
    public let padding: BotsiEdge
    public let verticalOffset: String?
    public let contentLayout: BotsiContentLayout
    
    private enum CodingKeys: String, CodingKey {
        case style
        case padding = "margin"
        case backgroundImage = "background_image"
        case verticalOffset  = "vertical_offset"
        case contentLayout   = "content_layout"
    }
}

@available(iOS 15.0, *)
public struct BotsiContentLayout: Codable, Sendable {
    public let padding: BotsiEdge?
    public let verticalOffset: String?
    public let align: BotsiAlign?
    public let spacing: String?
    public let layout: BotsiLayout?
}

@available(iOS 15.0, *)
public enum BotsiLayout: String, Codable, Sendable {
    case vertical = "Vertical"
    case horizontal = "Horizontal"
}
