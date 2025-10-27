//
//  BotsiTextModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
public struct BotsiTextModel: Decodable, Sendable, BotsiPaddingProvider {
    
    public let text: TextBlock
    public let maxLines: String?
    public let onOverflow: BotsiTextOverflow
    public let padding: BotsiEdge
    public let verticalOffset: String?
    
    public struct TextBlock: Decodable, Sendable, BotsiTextPropertiesProvider {
        public let text: String
        public let textFallback: String?
        public let font: BotsiLayoutModel.DefaultFont?
        public let customFont: BotsiCustomFont?
        public let size: String?
        public let align: BotsiAlign
        public let color: BotsiFillColor?

        private enum CodingKeys: String, CodingKey {
            case text, size, align, color, font
            case textFallback = "text_fallback"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            text = try container.decode(String.self, forKey: .text)
            textFallback = try container.decodeIfPresent(String.self, forKey: .textFallback)
            size = try container.decodeIfPresent(String.self, forKey: .size)
            align = try container.decode(BotsiAlign.self, forKey: .align)
            color = try container.decodeIfPresent(BotsiFillColor.self, forKey: .color)
            
            if let defaultFont = try? container.decode(BotsiLayoutModel.DefaultFont.self, forKey: .font) {
                self.font = defaultFont
                self.customFont = nil
            } else if let customFont = try? container.decode(BotsiCustomFont.self, forKey: .font) {
                self.font = nil
                self.customFont = customFont
            } else {
                self.font = nil
                self.customFont = nil
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case text
        case padding = "margin"
        case maxLines = "max_lines"
        case onOverflow = "on_overflow"
        case verticalOffset = "vertical_offset"
    }
}

@available(iOS 15.0, *)
public enum BotsiTextOverflow: String, Decodable, Sendable {
    case truncate
    case scale
}

@available(iOS 15.0, *)
extension BotsiTextModel {
    var maxLinesCount: Int? {
        guard let maxLines else { return nil }
        return Int(maxLines)
    }

    var verticalOffsetValue: CGFloat {
        verticalOffset?.toCGFloat() ?? 0
    }
}