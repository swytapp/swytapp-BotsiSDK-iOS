//
//  BotsiTextModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation
import SwiftUICore

@available(iOS 15.0, *)
public struct BotsiTextModel: Decodable, Sendable {
    
    public let text: TextBlock
    public let maxLines: String?
    public let onOverflow: BotsiTextOverflow
    public let margin: BotsiEdge
    public let verticalOffset: String?
    
    public struct TextBlock: Decodable, Sendable, BotsiTextBlockProvider {
        public let text: String
        public let textFallback: String?
        public let font: BotsiLayoutModel.DefaultFont
        public let size: String
        public let align: BotsiAlign
        public let color: BotsiFillColor

        public var textSize: CGFloat {
            CGFloat(Double(size) ?? 14)
        }

        private enum CodingKeys: String, CodingKey {
            case text, size, align, color, font
            case textFallback = "text_fallback"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case text
        case margin
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
