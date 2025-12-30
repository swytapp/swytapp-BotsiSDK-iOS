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
    public let spacing: CGFloat
    public let layout: BotsiLayout?

    private enum CodingKeys: String, CodingKey {
        case padding
        case verticalOffset = "vertical_offset"
        case align
        case spacing
        case layout
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        padding = try container.decodeIfPresent(BotsiEdge.self, forKey: .padding)
        verticalOffset = try container.decodeIfPresent(String.self, forKey: .verticalOffset)
        align = try container.decodeIfPresent(BotsiAlign.self, forKey: .align)
        spacing = try container.decodeCGFloat(forKey: .spacing)
        layout = try container.decodeIfPresent(BotsiLayout.self, forKey: .layout)
    }
}

@available(iOS 15.0, *)
public enum BotsiLayout: String, Codable, Sendable {
    case vertical = "Vertical"
    case horizontal = "Horizontal"
}
