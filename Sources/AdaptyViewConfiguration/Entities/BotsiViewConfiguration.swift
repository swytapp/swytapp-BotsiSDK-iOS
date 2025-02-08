//
//  BotsiViewConfiguration.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

package struct BotsiViewConfiguration: Sendable, Hashable {
    package let id: String
    package let locale: String
    package let isRightToLeft: Bool
    package let templateId: String
    package let screen: Screen
    package let bottomSheets: [String: BottomSheet]
    package let templateRevision: Int64
    package let selectedProducts: [String: String]
}

#if DEBUG
    package extension BotsiViewConfiguration {
        static func create(
            id: String = UUID().uuidString,
            locale: String = BotsiLocale.defaultPaywallLocale.id,
            isRightToLeft: Bool = false,
            templateId: String,
            screen: BotsiViewConfiguration.Screen,
            bottomSheets: [String: BotsiViewConfiguration.BottomSheet] = [:],
            templateRevision: Int64 = 0,
            selectedProducts: [String: String] = [:]
        ) -> Self {
            .init(
                id: id,
                locale: locale,
                isRightToLeft: isRightToLeft,
                templateId: templateId,
                screen: screen,
                bottomSheets: bottomSheets,
                templateRevision: templateRevision,
                selectedProducts: selectedProducts
            )
        }
    }
#endif

extension BotsiViewConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), templateId: \(templateId), templateRevision: \(templateRevision), locale: \(locale), isRightToLeft: \(isRightToLeft))"
    }
}
