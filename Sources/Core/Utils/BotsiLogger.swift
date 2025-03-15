//
//  BotsiLogger.swift
//  Botsi
//
//  Created by Vladyslav on 12.03.2025.
//

enum BotsiLog {
    static func debug(_ message: String) { print("💚 [DEBUG] \(message)") }
    static func verbose(_ message: String) { print("💜 [VERBOSE] \(message)") }
    static func warn(_ message: String)  { print("💛 [WARN]  \(message)") }
    static func info(_ message: String)  { print("💙 [INFO]  \(message)") }
    static func error(_ message: String) { print("❤️ [ERROR] \(message)") }
}
