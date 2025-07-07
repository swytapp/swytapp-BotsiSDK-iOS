//
//  BotsiTimerModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiTimerModel: Codable, Sendable {
    public let format: String      // "hh mm ss"
    public let separator: String      // "letter" | …
    public let startText: String
    public let beforeText: String
    public let afterText: String
    public let beforeTextFallback: String
    public let afterTextFallback: String
    public let style: TextStyle
    public let padding: CGFloat
    public let verticalOffset: String

    public struct TextStyle: Codable, Sendable {
        public let font: BotsiLayoutModel.DefaultFont
        public let size: String
        public let align: String
        public let color: String
        public let opacity: Int
    }

    private enum CodingKeys: String, CodingKey {
        case format, separator, style, padding
        case startText = "start_text"
        case beforeText = "before_text"
        case afterText = "after_text"
        case beforeTextFallback = "before_text_fallback"
        case afterTextFallback = "after_text_fallback"
        case verticalOffset = "vertical_offset"
    }
}
