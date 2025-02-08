//
//  BotsiStorefront+updates.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import Foundation

extension BotsiStorefront {
    public static var current: BotsiStorefront? {
        get async {
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                await BotsiStorefront.StoreKit2.current
            } else {
                await BotsiStorefront.StoreKit1.current
            }
        }
    }

    public static var updates: AsyncStream<BotsiStorefront> {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            BotsiStorefront.StoreKit2.updates
        } else {
            BotsiStorefront.StoreKit1.updates
        }
    }
}
