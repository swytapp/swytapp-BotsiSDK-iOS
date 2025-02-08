//
//  VC.Timer.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension BotsiViewSource {
    struct Timer: Sendable, Hashable {
        let id: String
        let state: BotsiViewConfiguration.Timer.State
        let format: [Item]
        let actions: [BotsiViewSource.Action]
        let horizontalAlign: BotsiViewConfiguration.HorizontalAlignment
        let defaultTextAttributes: TextAttributes?

        struct Item: Sendable, Hashable {
            let from: TimeInterval
            let stringId: String
        }
    }
}

extension BotsiViewSource.Localizer {
    func timer(_ from: BotsiViewSource.Timer) throws -> BotsiViewConfiguration.Timer {
        try .init(
            id: from.id,
            state: from.state,
            format: from.format.compactMap {
                guard let value = richText(
                    stringId: $0.stringId,
                    defaultTextAttributes: from.defaultTextAttributes
                ) else { return nil }

                return BotsiViewConfiguration.Timer.Item(
                    from: $0.from,
                    value: value
                )
            },
            actions: from.actions.map(action),
            horizontalAlign: from.horizontalAlign
        )
    }
}

extension BotsiViewSource.Timer: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case duration
        case behaviour
        case format
        case endTime = "end_time"
        case actions = "action"
        case horizontalAlign = "align"
    }

    enum BehaviourType: String, Codable {
        case everyAppear = "start_at_every_appear"
        case firstAppear = "start_at_first_appear"
        case firstAppearPersisted = "start_at_first_appear_persisted"
        case endAtLocalTime = "end_at_local_time"
        case endAtUTC = "end_at_utc_time"
        case custom
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)

        let behaviour = try container.decodeIfPresent(String.self, forKey: .behaviour)

        state =
            switch behaviour {
            case BehaviourType.endAtUTC.rawValue:
                try .endedAt(container.decode(BotsiViewSource.DateString.self, forKey: .endTime).utc)
            case BehaviourType.endAtLocalTime.rawValue:
                try .endedAt(container.decode(BotsiViewSource.DateString.self, forKey: .endTime).local)
            case .none:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .default)
            case BehaviourType.everyAppear.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .everyAppear)
            case BehaviourType.firstAppear.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .firstAppear)
            case BehaviourType.firstAppearPersisted.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .firstAppearPersisted)
            case BehaviourType.custom.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .custom)
            default:
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.behaviour], debugDescription: "unknown value '\(behaviour ?? "null")'"))
            }

        format =
            if let stringId = try? container.decode(String.self, forKey: .format) {
                [.init(from: 0, stringId: stringId)]
            } else {
                try container.decode([Item].self, forKey: .format)
            }

        actions =
            if let action = try? container.decodeIfPresent(BotsiViewSource.Action.self, forKey: .actions) {
                [action]
            } else {
                try container.decodeIfPresent([BotsiViewSource.Action].self, forKey: .actions) ?? []
            }

        horizontalAlign = try container.decodeIfPresent(BotsiViewConfiguration.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        let textAttributes = try BotsiViewSource.TextAttributes(from: decoder)
        defaultTextAttributes = textAttributes.isEmpty ? nil : textAttributes
    }
}

extension BotsiViewSource {
    struct DateString: Decodable {
        let utc: Date
        let local: Date

        init(from decoder: Decoder) throws {
            let value = try decoder.singleValueContainer().decode(String.self)
            let arrayString = value.components(separatedBy: CharacterSet(charactersIn: " -:.,;/\\"))
            let array = try arrayString.map {
                guard let value = Int($0) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "wrong date format  '\(value)'"))
                }
                return value
            }
            guard array.count >= 6 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "wrong date format  '\(value)'"))
            }

            var components = DateComponents(
                calendar: Calendar(identifier: .gregorian),
                year: array[0],
                month: array[1],
                day: array[2],
                hour: array[3],
                minute: array[4],
                second: array[5]
            )
            var utcComponents = components

            utcComponents.timeZone = TimeZone(identifier: "UTC")
            components.timeZone = TimeZone.current

            guard let utc = utcComponents.date, let local = components.date else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "wrong date '\(value)'"))
            }

            self.local = local
            self.utc = utc
        }
    }
}

extension BotsiViewSource.Timer.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case from
        case stringId = "string_id"
    }
}
