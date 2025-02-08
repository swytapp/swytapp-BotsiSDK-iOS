//
//  BotsiProfile.CustomAttributes.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

extension BotsiProfile {
    typealias CustomAttributes = [String: CustomAttributeValue]

    enum CustomAttributeValue: Sendable, Hashable {
        case none
        case string(String)
        case double(Double)
    }
}

extension BotsiProfile.CustomAttributeValue {
    var hasValue: Bool {
        switch self {
        case .none:
            false
        default:
            true
        }
    }

    var rawValue: (any Sendable)? {
        switch self {
        case .none:
            nil
        case let .string(value):
            value
        case let .double(value):
            value
        }
    }

    func validate() -> BotsiError? {
        switch self {
        case let .string(value):
            (value.isEmpty || value.count > 50) ? .wrongStringValueOfCustomAttribute() : nil
        default:
            nil
        }
    }
}

extension BotsiProfile.CustomAttributes {
    func convertToSimpleDictionary() -> [String: any Sendable] {
        [String: any Sendable](
            compactMap {
                guard let rawValue = $1.rawValue else { return nil }
                return ($0, rawValue)
            },
            uniquingKeysWith: { $1 }
        )
    }

    static func validateKey(_ key: String) -> BotsiError? {
        if key.isEmpty || key.count > 30 || key.range(of: ".*[^A-Za-z0-9._-].*", options: .regularExpression) != nil {
            return .wrongKeyOfCustomAttribute()
        }
        return nil
    }

    func validate() -> BotsiError? {
        if filter({ $1.hasValue }).count > 30 {
            return .wrongCountCustomAttributes()
        }
        return nil
    }
}

extension BotsiProfile.CustomAttributeValue: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .none
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .double(value ? 1.0 : 0.0)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Custom attributes support only Double or String")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .none:
            try container.encodeNil()
        case let .string(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        }
    }
}
