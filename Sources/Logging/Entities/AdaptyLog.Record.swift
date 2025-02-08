//
//  BotsiLog.Record.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 22.08.2024
//

import Foundation

extension Log {
    package typealias Record = BotsiLog.Record
}

extension BotsiLog {
    public struct Record: Sendable {
        public let date: Date
        public let level: Level
        public let message: String
        public let category: Category
        public let source: Source
    }
}

extension BotsiLog.Record: CustomStringConvertible, CustomDebugStringConvertible {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()

    private var dateAsString: String {
        Self.dateFormatter.string(from: date)
    }

    public var description: String {
        "\(dateAsString) \(level.description) \(category.description):\t\(message)"
    }

    public var debugDescription: String {
        "\(dateAsString) \(level.description) \(category.description) \(source.description):\t\(message)"
    }
}
