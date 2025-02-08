//
//  Screen.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension BotsiViewConfiguration {
    package struct Screen: Sendable, Hashable {
        static let defaultBackground: BotsiViewConfiguration.Background = .filling(.same(.solidColor(.black)))

        package let background: BotsiViewConfiguration.Background
        package let cover: Box?
        package let content: Element
        package let footer: Element?
        package let overlay: Element?
        package let selectedBotsiProductId: String?
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.Screen {
        static func create(
            background: BotsiViewConfiguration.Background = BotsiViewConfiguration.Screen.defaultBackground,
            cover: BotsiViewConfiguration.Box? = nil,
            content: BotsiViewConfiguration.Element,
            footer: BotsiViewConfiguration.Element? = nil,
            overlay: BotsiViewConfiguration.Element? = nil,
            selectedBotsiProductId: String? = nil
        ) -> Self {
            .init(
                background: background,
                cover: cover,
                content: content,
                footer: footer,
                overlay: overlay,
                selectedBotsiProductId: selectedBotsiProductId
            )
        }
    }
#endif
