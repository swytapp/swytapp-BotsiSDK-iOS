//
//  Button.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension BotsiViewConfiguration {
    package struct Button: Sendable, Hashable {
        package let actions: [ActionAction]
        package let normalState: Element
        package let selectedState: Element?
        package let selectedCondition: StateCondition?
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.Button {
        static func create(
            actions: [BotsiViewConfiguration.ActionAction],
            normalState: BotsiViewConfiguration.Element,
            selectedState: BotsiViewConfiguration.Element? = nil,
            selectedCondition: BotsiViewConfiguration.StateCondition? = nil
        ) -> Self {
            .init(
                actions: actions,
                normalState: normalState,
                selectedState: selectedState,
                selectedCondition: selectedCondition
            )
        }
    }
#endif
