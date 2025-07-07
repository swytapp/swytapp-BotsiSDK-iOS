//
//  BotsiCardModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiCardModel: Decodable, Sendable {
    
    public struct Style: Codable, Sendable {
        public let color: String
        public let opacity: Int
        public let borderColor: String
        public let borderOpacity: Int?
        public let borderThickness: CGFloat?
        public let radius: CGFloat

        private enum CodingKeys: String, CodingKey {
            case color
            case opacity
            case borderColor = "border_color"
            case borderOpacity = "border_opacity"
            case borderThickness = "border_thickness"
            case radius
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.color = try container.decodeIfPresent(String.self, forKey: .color) ?? ""
            self.opacity = try container.decodeIfPresent(Int.self, forKey: .opacity) ?? 100
            self.borderColor = try container.decodeIfPresent(String.self, forKey: .borderColor) ?? ""
            self.borderOpacity = try container.decodeIfPresent(Int.self, forKey: .borderOpacity) ?? 100

            if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: .borderThickness) {
                self.borderThickness = CGFloat(doubleValue)
            } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .borderThickness),
                      let doubleValue = Double(stringValue) {
                self.borderThickness = CGFloat(doubleValue)
            } else {
                self.borderThickness = nil
            }

            if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: .radius) {
                self.radius = CGFloat(doubleValue)
            } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .radius),
                      let doubleValue = Double(stringValue) {
                self.radius = CGFloat(doubleValue)
            } else {
                self.radius = 0
            }
        }
    }
    
    public let style: Style
    public let backgroundImage: String
    public let margin: BotsiEdge?
    public let verticalOffset: String?
    public let contentLayout: ContentLayout
    
    private enum CodingKeys: String, CodingKey {
        case style, margin
        case backgroundImage = "background_image"
        case verticalOffset  = "vertical_offset"
        case contentLayout   = "content_layout"
    }
}

@available(iOS 15.0, *)
public struct ContentLayout: Codable, Sendable {
    public let padding: BotsiEdge
    public let verticalOffset: String?
    public let align: BotsiAlign?
}

