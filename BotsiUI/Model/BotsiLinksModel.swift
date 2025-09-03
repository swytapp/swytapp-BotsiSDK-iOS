//
//  BotsiLinksModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiLinksModel: Decodable, Sendable, BotsiPaddingProvider {
    public let hasTermOfService: Bool
    public let termOfService: LinkItem?
    public let hasPrivacyPolicy: Bool
    public let privacyPolicy: LinkItem?
    public let hasRestoreButton: Bool
    public let restoreButton: LinkItem?
    public let hasLoginButton: Bool
    public let loginButton: LinkItem?
    public let style: Style
    public let padding: BotsiEdge
    public let verticalOffset: String
    public let contentLayout: BotsiContentLayout

    public var spacing: CGFloat {
        contentLayout.spacing?.toCGFloat() ?? 0
    }

    public struct LinkItem: Codable, Sendable {
        public let text: String
        public let url: String?
        public let textFallback: String
        public let urlFallback: String?

        private enum CodingKeys: String, CodingKey {
            case text, url
            case textFallback = "text_fallback"
            case urlFallback  = "url_fallback"
        }
    }

    public struct ButtonTitle: Codable, Sendable {
        public let text: String
        public let textFallback: String?

        private enum CodingKeys: String, CodingKey {
            case text
            case textFallback = "text_fallback"
        }
    }

    public struct Style: Decodable, Sendable, BotsiTextPropertiesProvider {
        public let font: BotsiLayoutModel.DefaultFont
        public let size: String
        public let color: BotsiFillColor
        public let dividersColor: BotsiFillColor?
        public let dividersThicknessString: String?

        public var dividersThickness: CGFloat {
            dividersThicknessString?.toCGFloat() ?? 0
        }

        private enum CodingKeys: String, CodingKey {
            case font, size, color, opacity
            case dividersColor = "dividers_color"
            case dividersThicknessString = "dividers_thickness"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            font = try container.decode(BotsiLayoutModel.DefaultFont.self, forKey: .font)
            size = try container.decode(String.self, forKey: .size)
            color = try container.decode(BotsiFillColor.self, forKey: .color)
            dividersColor = try container.decodeIfPresent(BotsiFillColor.self, forKey: .dividersColor)
            dividersThicknessString = try container.decodeIfPresent(String.self, forKey: .dividersThicknessString)
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
