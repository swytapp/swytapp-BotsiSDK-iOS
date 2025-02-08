//
//  Column.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.05.2024
//
//

import Foundation

extension BotsiViewConfiguration {
    package struct Column: Sendable, Hashable {
        package let spacing: Double
        package let items: [GridItem]
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.Column {
        static func create(
            spacing: Double = 0,
            items: [BotsiViewConfiguration.GridItem]
        ) -> Self {
            .init(
                spacing: spacing,
                items: items
            )
        }
    }
#endif
