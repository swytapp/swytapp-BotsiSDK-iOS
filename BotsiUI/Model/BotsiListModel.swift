//
//  BotsiListModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiListModel: Codable, Sendable {
    
    public let padding: String?
    public let verticalOffset: String?
    public let itemSpacing: String?
    public let textSpacing: String?
    public let width: String?
    public let height: String?
    
    public let defaultIcon: String?
    public let iconPlacement: String?
    public let defaultColor: String?
    public let defaultOpacity: Int?
    
    public let connectorThickness: String?
    public let connectorColor: String?
    public let connectorOpacity: Int?
    
    public let titleTextStyle: BotsiTextStyleModel?
    public let captionTextStyle: BotsiTextStyleModel?
    
    private enum CodingKeys: String, CodingKey {
        case padding, width, height
        case verticalOffset = "vertical_offset"
        case itemSpacing = "item_spacing"
        case textSpacing = "text_spacing"
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
}

@available(iOS 15.0, *)
public struct BotsiListItemModel: Codable, Sendable, Identifiable {
    
    public let id: String?
    
    public var safeID: String {
        id ?? UUID().uuidString
    }
    
    public let icon: String?
    public let connectorThickness: String?
    public let connectorColor: String
    public let connectorOpacity: Int?
    
    public let titleText: String?
    public let titleTextFallback: String?
    public let titleTextStyle: BotsiTextStyleModel
    
    public let captionText: String?
    public let captionTextFallback: String?
    public let captionTextStyle: BotsiTextStyleModel
    
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
