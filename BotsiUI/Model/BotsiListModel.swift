//
//  BotsiListModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiListModel: Decodable, Sendable, BotsiPaddingProvider {
    
    public let padding: BotsiEdge
    public let verticalOffsetString: String?
    public let itemSpacingString: String?
    public let textSpacingString: String?
    public let width: String?
    public let height: String?
    
    public let defaultIcon: BotsiListModel.DefaultIcon
    public let iconPlacement: BotsiAlign
    public let defaultColor: BotsiFillColor?
    public let defaultOpacity: Int?
    
    public let connectorThickness: String?
    public let connectorColor: String?
    public let connectorOpacity: Int?
    
    public let titleTextStyle: BotsiTextStyleModel?
    public let captionTextStyle: BotsiTextStyleModel?
    
    public var imageSize: CGSize {
        CGSize(width: width?.toCGFloat() ?? 30, height: height?.toCGFloat() ?? 30)
    }
    
    public var textSpacing: CGFloat {
        textSpacingString?.toCGFloat() ?? 0
    }
    
    public var itemSpacing: CGFloat {
        itemSpacingString?.toCGFloat() ?? 8
    }
    
    public var verticalOffset: CGFloat {
        verticalOffsetString?.toCGFloat() ?? 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case padding, width, height
        case verticalOffsetString = "vertical_offset"
        case itemSpacingString = "item_spacing"
        case textSpacingString = "text_spacing"
        case defaultIcon = "default_icon"
        case iconPlacement = "icon_placement"
        case defaultColor = "default_color"
        case defaultOpacity = "default_opacity"
        case connectorThickness = "connector_thickness"
        case connectorColor = "connector_color"
        case connectorOpacity = "connector_opacity"
        case titleTextStyle = "title_text_style"
        case captionTextStyle = "caption_text_style"
    }
    
    public enum DefaultIcon: String, Decodable, Sendable {
        case tick
        case checkmark
        case dot
        
        var icon: String {
            switch self {
            case .tick:
                return "checkmark.circle.fill"
            case .checkmark:
                return "checkmark"
            case .dot:
                return "circle.fill"
            }
        }
    }
}

@available(iOS 15.0, *)
public struct BotsiListItemModel: Decodable, Sendable, Identifiable {
    
    public var id: String?

    public let icon: String?
    public let connectorThickness: String?
    public let connectorColor: BotsiFillColor?
    public let connectorOpacity: Int?
    
    public let titleText: String?
    public let titleTextFallback: String?
    public let titleTextStyle: BotsiTextStyleModel?
    
    public let captionText: String?
    public let captionTextFallback: String?
    public let captionTextStyle: BotsiTextStyleModel?
    
    public var thickness: CGFloat {
        connectorThickness?.toCGFloat() ?? .zero
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, icon
        case connectorThickness = "connector_thickness"
        case connectorColor = "connector_color"
        case connectorOpacity = "connector_opacity"
        case titleText = "title_text"
        case titleTextFallback = "title_text_fallback"
        case titleTextStyle = "title_text_style"
        case captionText = "caption_text"
        case captionTextFallback = "caption_text_fallback"
        case captionTextStyle = "caption_text_style"
    }
}
