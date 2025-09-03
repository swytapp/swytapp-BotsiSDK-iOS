//
//  BotsiLayoutModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiLayoutModel: Decodable, Sendable {
    
    public let template: TemplateContainer?
    public let darkMode: Bool?
    public let purchaseFlow: String?
    public let fillColor: BotsiFillColor?
    public let defaultFont: DefaultFont
    public let contentLayout: ContentLayout
    public let topButtons: [TopButton]
    
    public var buttons: [TopButton] {
        return topButtons.filter { $0.enabled }
    }
    
    private enum CodingKeys: String, CodingKey {
        case template
        case darkMode = "dark_mode"
        case purchaseFlow = "purchase_flow"
        case fillColor = "fill_color"
        case defaultFont = "default_font"
        case contentLayout = "content_layout"
        case topButtons = "top_buttons"
    }
    
    // template ---------------------------------------------------------------
    public struct Template: Codable, Sendable {
        public let image: String
        public let name: String
        public let id: String
    }
    
    // default_font -----------------------------------------------------------
    public struct FontType: Codable, Sendable {
        public let name: String
        public let id: String
        public let fontWeight: Int
        public let fontStyle: String
        public let isSelected: Bool
    }
    
    public struct DefaultFont: Codable, Sendable {
        public let id: String
        public let name: String
        public let isSelected: Bool
        public let types: [FontType]

         /// Returns the selected font type from the font's types array
        public var selectedFontType: BotsiLayoutModel.FontType? {
            types.first { $0.isSelected }
        }

        public var fontWeight: Int {
            selectedFontType?.fontWeight ?? 400
        }

        public var isItalic: Bool {
            guard let selectedFontType else { return false }
            return selectedFontType.fontStyle.lowercased() == "italic"
        }
    }
    
    // content_layout ---------------------------------------------------------
    public struct ContentLayout: Codable, Sendable {
        public let margin: BotsiEdge      // "76 16 16 16"
        public let spacing: String
    }
    
    // top_buttons ------------------------------------------------------------
    public struct ButtonText: Decodable, Sendable, BotsiTextPropertiesProvider {
        public let text: String
        public let font: DefaultFont
        public let size: String
        public let color: BotsiFillColor
        public let opacity: Int?
    }
    
    public struct ButtonIcon: Decodable, Sendable {
        public let type:  String
        public let color: BotsiFillColor
        public let opacity: Int?
    }
    
    public struct TopButton: Decodable, Identifiable, Sendable {
        public let id = UUID()
        public let action: String
        public let enabled: Bool
        public let actionId: BotsiActionType?
        public let buttonType: BotsiButtonType?
        public let buttonAlign: BotsiAlign
        public let delay: Int
        public let style: BotsiButtonStyle
        public let text: ButtonText
        public let icon: ButtonIcon
        
        public var iconOpacity: CGFloat {
            CGFloat(icon.opacity ?? 100) / 100.0
        }
        
        public var styleBorderOpacity: CGFloat {
            CGFloat(style.borderOpacity ?? 100) / 100.0
        }
        
        private enum CodingKeys: String, CodingKey {
            case action, enabled, actionId
            case buttonType  = "button_type"
            case buttonAlign = "button_align"
            case delay, style, text, icon
        }
    }
}

@available(iOS 15.0, *)
public enum BotsiActionType: String, Codable, Sendable {
    case close = "Close"
    case restore = "Restore"
    case login = "Login"
    case custom = "Custom"
}

@available(iOS 15.0, *)
public struct BotsiButtonStyle: Decodable, Sendable {
    public let fillColor: BotsiFillColor?
    public let borderColor: BotsiFillColor
    public let borderOpacity: Int?
    public let borderThickness: String
    public let radius: String

    private enum CodingKeys: String, CodingKey {
        case color, opacity, radius
        case fillColor = "fill_color"
        case borderColor = "border_color"
        case borderOpacity = "border_opacity"
        case borderThickness = "border_thickness"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.fillColor = try? container.decode(BotsiFillColor.self, forKey: .fillColor)
        self.borderColor = try container.decode(BotsiFillColor.self, forKey: .borderColor)
        self.borderOpacity = try? container.decode(Int.self, forKey: .borderOpacity)
        self.radius = try container.decode(String.self, forKey: .radius)

        if let thickness = try? container.decode(String.self, forKey: .borderThickness) {
            self.borderThickness = thickness
        } else if let thicknessInt = try? container.decode(Int.self, forKey: .borderThickness) {
            self.borderThickness = String(thicknessInt)
        } else {
            self.borderThickness = "0"
        }
    }
}

@available(iOS 15.0, *)
public struct BotsiEdge: Codable, Sendable {
    public let left: CGFloat
    public let top: CGFloat
    public let right: CGFloat
    public let bottom: CGFloat
    
    public static var defaultEdge: BotsiEdge {
        .init(left: 0, top: 0, right: 0, bottom: 0)
    }

    public init(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)

        let parts = rawString
            .split(separator: " ")
            .compactMap { CGFloat(Double($0) ?? 0) }

        switch parts.count {
        case 1:
            self.init(left: parts[0], top: parts[0], right: parts[0], bottom: parts[0])
        case 4:
            self.init(left: parts[3], top: parts[0], right: parts[1], bottom: parts[2])
        default:
            self.init(left: 0, top: 0, right: 0, bottom: 0)
        }
    }
}

@available(iOS 15.0, *)
public enum TemplateContainer: Decodable, Sendable {
    case template(BotsiLayoutModel.Template)
    case id(Int)
    
    var value: BotsiLayoutModel.Template? {
        switch self {
        case .template(let tpl): return tpl
        case .id: return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let tpl = try? container.decode(BotsiLayoutModel.Template.self) {
            self = .template(tpl)
        } else if let int = try? container.decode(Int.self) {
            self = .id(int)
        } else {
            throw DecodingError.typeMismatch(
                TemplateContainer.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected Template or Int"
                )
            )
        }
    }
}

public enum BotsiAlign: String, Codable, Sendable {
    case left
    case center
    case right
    case bottom
    case top
    
    public var alignments: (horizontal: HorizontalAlignment, vertical: VerticalAlignment, frame: Alignment, text: TextAlignment) {
        switch self {
        case .left:
            return (.leading, .center, .leading, .leading)
        case .center:
            return (.center, .center, .center, .center)
        case .right:
            return (.trailing, .center, .trailing, .trailing)
        case .bottom:
            return (.leading, .bottom, .bottom, .leading)
        case .top:
            return (.leading, .top, .top, .leading)
        }
    }
}

public enum BotsiButtonType: String, Codable, Sendable {
    case icon = "Icon"
    case text = "Text"
}
