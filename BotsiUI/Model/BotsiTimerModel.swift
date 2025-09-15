//
//  BotsiTimerModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiTimerModel: Decodable, Sendable, BotsiPaddingProvider {
    public let format: String
    public let separator: BotsiTimerSeparator
    public let startText: String
    public let beforeText: String
    public let afterText: String
    public let padding: BotsiEdge
    public let verticalOffset: String
    public let style: BotsiTextStyleModel
    public let timerMode: TimerMode
    public let customActionID: String?
    public let triggerCustomAction: Bool
    
    enum CodingKeys: String, CodingKey {
        case format, separator
        case startText = "start_text"
        case beforeText = "before_text"
        case afterText = "after_text"
        case padding
        case verticalOffset = "vertical_offset"
        case style
        case timerMode = "timer_mode"
        case customActionID = "custom_action_id"
        case triggerCustomAction = "trigger_custom_action"
    }

    public enum TimerMode: String, Decodable, Sendable {
        case reset = "Reset timer on every paywall view"
        case appLaunchReset = "Reset timer on every app lunch"
        case keep = "Keep timer across app lunches"
        case defined = "Developer defined"
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
