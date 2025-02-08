//
//  BottomSheet.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension BotsiViewConfiguration {
    package struct BottomSheet: Sendable, Hashable {
        package let content: Element
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.BottomSheet {
        static func create(
            content: BotsiViewConfiguration.Element
        ) -> Self {
            .init(
                content: content
            )
        }
    }
#endif
