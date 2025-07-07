//
//  BotsiBlockType.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

public enum BotsiBlockType: String, Decodable, Sendable {
    case layout        = "layout"
    case heroImage     = "hero_image"
    case text          = "text"
    case list          = "list"
    case listItem      = "list_nested"
    case footer        = "footer"
    case products      = "products"
    case productItem   = "product_item"
    case button        = "button"
    case image         = "image"
    case card          = "card"
    case links         = "links"
    case carousel      = "carousel"
    case timer         = "timer"
    case toggleControl = "toggle_control"
    case localization  = "localization"
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawType = try container.decode(String.self)
        
        self = BotsiBlockType(rawValue: rawType) ?? .unknown
    }
}


// MARK: - Unified block
@available(iOS 15.0, *)
public struct BotsiPaywallBlock: Decodable, Sendable {
    public let meta: BotsiBlockMeta
    public let content: BotsiBlockContent?
    public let children: [BotsiPaywallBlock]?

    private enum CodingKeys: String, CodingKey { case meta, content, children }
}


@available(iOS 15.0, *)
public struct BotsiPaywallContentStructure: Sendable {
    public let layout: BotsiPaywallBlock?
    public let content: [BotsiPaywallBlock]?
    public let footer: BotsiPaywallBlock?
    public let heroImage: BotsiPaywallBlock?
}
