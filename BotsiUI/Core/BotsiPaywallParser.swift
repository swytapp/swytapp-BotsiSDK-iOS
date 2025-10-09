//
//  BotsiPaywallParser.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 19.06.2025.
//

import Foundation

// MARK: - Type fore store universal content
public typealias BotsiBlockContentValue = [String: CodableValue]

@available(iOS 15.0, *)
public final class BotsiPaywallParser {
    
    public static func parseStructure(from data: Data) throws -> BotsiPaywallContentStructure {
        let rawContainer = try JSONDecoder().decode(BotsiRawDataContainer.self, from: data)
        
        let parsedBlocks = rawContainer.data.map { parseBlock($0) }
        
        let layout = parsedBlocks.first { $0.meta.type == .layout }
        let footer = parsedBlocks.first { $0.meta.type == .footer }
        let heroImage = parsedBlocks.first { $0.meta.type == .heroImage }
        let content = parsedBlocks.filter { block in
            let type = block.meta.type
            return type != .layout && type != .footer && type != .heroImage
        }
        
        return BotsiPaywallContentStructure(layout: layout, content: content, footer: footer, heroImage: heroImage)
    }
    
    private static func parseBlock(_ raw: BotsiRawBlock) -> BotsiPaywallBlock {
        let parsedContent = parseContent(type: raw.meta.type, content: raw.content) ?? .unknown(.init())
        let parsedChildren = raw.children?.map { parseBlock($0) }
        
        return BotsiPaywallBlock(meta: raw.meta, content: parsedContent, children: parsedChildren ?? [])
    }
    
    private static func parseContent(type: BotsiBlockType?, content: BotsiBlockContentValue?) -> BotsiBlockContent? {
        guard let type = type, let content = content else { return nil }
        
        do {
            let jsonData = try JSONEncoder().encode(content)
            let decoder = JSONDecoder()
            
            switch type {
            case .layout:
                return .layout(try decoder.decode(BotsiLayoutModel.self, from: jsonData))
            case .heroImage:
                return .heroImage(try decoder.decode(BotsiHeroImageModel.self, from: jsonData))
            case .timer:
                return .timer(try decoder.decode(BotsiTimerModel.self, from: jsonData))
            case .carousel:
                return .carousel(try decoder.decode(BotsiCarouselModel.self, from: jsonData))
            case .links:
                return .links(try decoder.decode(BotsiLinksModel.self, from: jsonData))
            case .text:
                return .text(try decoder.decode(BotsiTextModel.self, from: jsonData))
            case .image:
                return .image(try decoder.decode(BotsiImageModel.self, from: jsonData))
            case .card:
                return .card(try decoder.decode(BotsiCardModel.self, from: jsonData))
            case .footer:
                return .footer(try decoder.decode(BotsiFooterModel.self, from: jsonData))
            case .list:
                return .list(try decoder.decode(BotsiListModel.self, from: jsonData))
            case .listItem:
                return .listItem(try decoder.decode(BotsiListItemModel.self, from: jsonData))
            case .button:
                return .button(try decoder.decode(BotsiButtonModel.self, from: jsonData))
            case .localization:
                return .localization(try decoder.decode(BotsiLocalizationModel.self, from: jsonData))
            case .products:
                return .products(try decoder.decode(BotsiProductsModel.self, from: jsonData))
            case .productItem:
                return .productItem(try decoder.decode(BotsiProductItemModel.self, from: jsonData))
            case .toggleControl:
                return .toggleControl(try decoder.decode(BotsiToggleControlModel.self, from: jsonData))
            case .toggleOn:
                return .toggleOn(try decoder.decode(BotsiToggleOnModel.self, from: jsonData))
            case .toggleOff:
                return .toggleOff(try decoder.decode(BotsiToggleOffModel.self, from: jsonData))
            case .tabControl:
                return .tabControl(try decoder.decode(BotsiTabControlModel.self, from: jsonData))
            case .tab:
                return .tab(try decoder.decode(BotsiTabModel.self, from: jsonData))
            case .basePlans:
                return .basePlans(try decoder.decode(BotsiMorePlansModel.self, from: jsonData))
            case .morePlans:
                return .morePlans(try decoder.decode(BotsiMorePlansModel.self, from: jsonData))
            case .moreButton:
                return .moreButton(try decoder.decode(BotsiMoreButtonModel.self, from: jsonData))
            case .unknown:
                return .unknown(nil)
            }
        } catch {
#if DEBUG
            print("Failed to parse content of type \(type): \(error)")
#endif
            return nil
        }
    }
}

@available(iOS 15.0, *)
public struct BotsiRawDataContainer: Decodable {
    public let data: [BotsiRawBlock]
}

@available(iOS 15.0, *)
public struct BotsiRawBlock: Decodable {
    public let meta: BotsiBlockMeta
    public let content: BotsiBlockContentValue?
    public let children: [BotsiRawBlock]?
    
    enum CodingKeys: String, CodingKey {
        case meta
        case content
        case children
    }
}

public enum CodableValue: Codable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([CodableValue])
    case dictionary([String: CodableValue])
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: CodableValue].self) {
            self = .dictionary(value)
        } else if let value = try? container.decode([CodableValue].self) {
            self = .array(value)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "CodableValue: Unsupported JSON value"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):   try container.encode(value)
        case .int(let value):      try container.encode(value)
        case .double(let value):   try container.encode(value)
        case .bool(let value):     try container.encode(value)
        case .array(let value):    try container.encode(value)
        case .dictionary(let value): try container.encode(value)
        case .null:                try container.encodeNil()
        }
    }
}
