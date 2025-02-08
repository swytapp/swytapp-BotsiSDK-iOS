//
//  VC.Button.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension BotsiViewSource {
    struct Button: Sendable, Hashable {
        let actions: [BotsiViewSource.Action]
        let normalState: BotsiViewSource.Element
        let selectedState: BotsiViewSource.Element?
        let selectedCondition: BotsiViewConfiguration.StateCondition?
    }
}

extension BotsiViewSource.Localizer {
    func button(_ from: BotsiViewSource.Button) throws -> BotsiViewConfiguration.Button {
        try .init(
            actions: from.actions.map(action),
            normalState: element(from.normalState),
            selectedState: from.selectedState.map(element),
            selectedCondition: from.selectedCondition
        )
    }

    func buttonAction(_ from: BotsiViewConfiguration.ActionAction) throws -> BotsiViewConfiguration.ActionAction {
        guard case let .openUrl(stringId) = from else { return from }
        return .openUrl(urlIfPresent(stringId))
    }
}

extension BotsiViewSource.Button: Decodable {
    enum CodingKeys: String, CodingKey {
        case actions = "action"
        case normalState = "normal"
        case selectedState = "selected"
        case selectedCondition = "selected_condition"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actions =
            if let action = try? container.decode(BotsiViewSource.Action.self, forKey: .actions) {
                [action]
            } else {
                try container.decode([BotsiViewSource.Action].self, forKey: .actions)
            }
        try self.init(
            actions: actions,
            normalState: container.decode(BotsiViewSource.Element.self, forKey: .normalState),
            selectedState: container.decodeIfPresent(BotsiViewSource.Element.self, forKey: .selectedState),
            selectedCondition: container.decodeIfPresent(BotsiViewConfiguration.StateCondition.self, forKey: .selectedCondition)
        )
    }
}
