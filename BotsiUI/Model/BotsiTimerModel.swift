//
//  BotsiTimerModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiTimerModel: Decodable, Sendable {
    public let format: String
    public let separator: BotsiTimerSeparator
    public let startText: String
    public let beforeText: String
    public let afterText: String
    public let padding: BotsiEdge
    public let verticalOffset: String
    public let style: BotsiTextStyleModel
    
    enum CodingKeys: String, CodingKey {
        case format, separator
        case startText = "start_text"
        case beforeText = "before_text"
        case afterText = "after_text"
        case padding
        case verticalOffset = "vertical_offset"
        case style
    }
}

@available(iOS 15.0, *)
public enum BotsiTimerFormat: String, Decodable, Sendable {
    case ddhhmmss = "dd hh mm ss"
    case hhmmss = "hh mm ss"
    case mmss = "mm ss"
    case ss = "ss"
}

@available(iOS 15.0, *)
public enum BotsiTimerSeparator: String, Decodable, Sendable {
    case colon, dash, space, letter
    
    var string: String {
        switch self {
        case .colon: return ":"
        case .dash: return "-"
        case .space: return " "
        case .letter: return "d h m s"
        }
    }
}
