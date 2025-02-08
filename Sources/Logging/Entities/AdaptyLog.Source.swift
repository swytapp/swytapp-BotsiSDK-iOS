//
//  BotsiLog.Source.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 24.08.2024
//

import Foundation

extension Log {
    package typealias Source = BotsiLog.Source
}

extension BotsiLog {
    public struct Source: Equatable, Sendable {
        public let fileName: String
        public let functionName: String
        public let lineNumber: UInt
    }
}

extension BotsiLog.Source: CustomStringConvertible {
    public var description: String { "\(fileName)#\(lineNumber)" }
}
