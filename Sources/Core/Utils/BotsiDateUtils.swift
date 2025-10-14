//
//  BotsiDateUtils.swift
//  Botsi
//
//  Created by Vladyslav on 19.07.2025.
//

import Foundation

extension Date {
    /// Parses a date string in various ISO 8601 formats
    /// - Parameter string: The date string to parse
    /// - Returns: A Date object
    /// - Throws: BotsiError.customError if the string cannot be parsed
    public static func parseISO8601(from string: String) throws -> Date {
        let formatters: [DateFormatter] = [
            // e.g. ISO 8601 format with milliseconds: "2025-07-19T08:26:46.000Z"
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                formatter.timeZone = TimeZone(abbreviation: "UTC")
                return formatter
            }(),
            // e.g. ISO 8601 format without milliseconds: "2025-07-19T08:26:46Z"
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                formatter.timeZone = TimeZone(abbreviation: "UTC")
                return formatter
            }(),
            // e.g. Date only format: "2025-07-19"
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone(abbreviation: "UTC")
                return formatter
            }()
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        
        throw BotsiError.customError("Date Parsing", "Unable to parse date string: \(string)")
    }
    
    public func toISO8601String() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: self)
    }
    
    public func toISO8601DateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: self)
    }
} 
