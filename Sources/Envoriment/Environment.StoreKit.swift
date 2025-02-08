//
//  Environment.StoreKit.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 25.09.2024
//

import Foundation

extension Environment {
    enum StoreKit {
        static let name = "app_store"

        static let storeKit2Enabled: Bool =
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                true
            } else {
                false
            }

        @BotsiActor
        private static var _lastStorefront: BotsiStorefront?

        @BotsiActor
        static var storefront: BotsiStorefront? {
            get async {
                if let storefront = await BotsiStorefront.current {
                    _lastStorefront = storefront
                    return storefront
                } else {
                    return _lastStorefront
                }
            }
        }
    }
}
