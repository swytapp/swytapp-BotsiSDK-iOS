//
//  Section.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.05.2024
//
//

import Foundation

extension BotsiViewConfiguration {
    package struct Section: Sendable, Hashable {
        package let id: String
        package let index: Int
        package let content: [Element]
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.Section {
        static func create(
            id: String = UUID().uuidString,
            index: Int = 0,
            content: [BotsiViewConfiguration.Element]
        ) -> Self {
            .init(
                id: id,
                index: index,
                content: content
            )
        }
    }
#endif
