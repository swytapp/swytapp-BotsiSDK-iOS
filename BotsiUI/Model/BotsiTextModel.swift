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
    public let onOverflow: String
    public let margin: BotsiEdge?
    public let verticalOffset: String?
    
    public struct TextBlock: Decodable, Sendable {
        public let text: String
        public let textFallback: String?
        public let font: BotsiLayoutModel.DefaultFont
        public let size: StringOrInt
        public let align: String
        public let color: String
        public let opacity: Int

        private enum CodingKeys: String, CodingKey {
            case text, size, align, color, opacity
            case textFallback = "text_fallback"
            case font
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
extension BotsiTextModel {
    
    var textSize: CGFloat {
        switch text.size {
        case .int(let value):
            return CGFloat(value)
        case .string(let str):
            return CGFloat(Double(str) ?? 14)
        }
    }
    
    var textOpacity: Double {
        return Double(text.opacity) / 100.0
    }
    
    var textAlignment: TextAlignment {
        switch text.align.lowercased() {
        case "center": return .center
        case "right": return .trailing
        default: return .leading
        }
    }
    
    var truncationMode: Text.TruncationMode {
        switch onOverflow.lowercased() {
        case "ellipsis": return .tail
        case "clip": return .head
        default: return .tail
        }
    }

    var maxLinesCount: Int? {
        guard let maxLines else { return nil }
        return Int(maxLines)
    }

    var verticalOffsetValue: CGFloat {
        verticalOffset?.toCGFloat() ?? 0
    }
}
