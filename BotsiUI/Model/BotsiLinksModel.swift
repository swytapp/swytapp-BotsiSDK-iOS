//
//  BotsiLinksModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiLinksModel: Decodable, Sendable {
    
    public let hasTermOfService: Bool
    public let termOfService: LinkItem?
    public let hasPrivacyPolicy: Bool
    public let privacyPolicy: LinkItem?
    public let hasRestoreButton: Bool
    public let restoreButton: ButtonTitle?
    public let hasLoginButton: Bool
    public let loginButton: ButtonTitle?
    public let style: Style
    public let padding: String?
    public let verticalOffset: String
    public let contentLayout: ContentLayout

    public struct LinkItem: Codable, Sendable {
        public let text: String
        public let url: String
        public let textFallback: String?
        public let urlFallback: String?
        
        private enum CodingKeys: String, CodingKey {
            case text, url
            case textFallback = "text_fallback"
            case urlFallback  = "url_fallback"
        }
    }
    
    public struct ButtonTitle: Codable, Sendable {
        public let text: String
        public let font: BotsiLayoutModel.DefaultFont?
        public let size: String?
        public let color: String?
        public let opacity: Int?
    }
    
    public struct ContentLayout: Decodable, Sendable {
        public let padding: String?
        public let verticalOffset: String?
        public let align: String?
    }
    
    public struct Style: Codable, Sendable {
        public let color: String?
        public let opacity: Int?
        public let borderColor: String?
        public let borderOpacity: Int?
        public let borderThickness: Int?
        public let radius: String?
        
        private enum CodingKeys: String, CodingKey {
            case opacity, radius, color
            case borderColor = "border_color"
            case borderOpacity = "border_opacity"
            case borderThickness = "border_thickness"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case style, padding
        case hasTermOfService = "has_term_of_service"
        case termOfService = "term_of_service"
        case hasPrivacyPolicy = "has_privacy_policy"
        case privacyPolicy = "privacy_policy"
        case hasRestoreButton = "has_restore_button"
        case restoreButton = "restore_button"
        case hasLoginButton = "has_login_button"
        case loginButton = "login_button"
        case verticalOffset = "vertical_offset"
        case contentLayout = "content_layout"
    }
}
