//
//  BotsiProfile.Gender.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

extension BotsiProfile {
    public enum Gender: Sendable, Hashable {
        case female
        case male
        case other
    }
}

extension BotsiProfile.Gender: CustomStringConvertible {
    public var description: String {
        switch self {
        case .female: "female"
        case .male: "male"
        case .other: "other"
        }
    }
}

extension BotsiProfile.Gender: Codable {
    enum CodingValues: String {
        case female = "f"
        case male = "m"
        case other = "o"
    }

    public init(from decoder: Decoder) throws {
        let value = try CodingValues(rawValue: decoder.singleValueContainer().decode(String.self))
        switch value {
        case .female: self = .female
        case .male: self = .male
        case .other: self = .other
        default: self = .other
        }
    }

    public func encode(to encoder: Encoder) throws {
        let value: CodingValues =
            switch self {
            case .female: .female
            case .male: .male
            case .other: .other
            }
        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}
