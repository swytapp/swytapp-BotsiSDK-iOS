//
//  SK1Storefront.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

typealias SK1Storefront = SKStorefront

extension SK1Storefront {
    var asBotsiStorefront: BotsiStorefront {
        .init(id: identifier, countryCode: countryCode)
    }
}

private let log = Log.storeFront

extension BotsiStorefront {
    enum StoreKit1 {
        static var current: BotsiStorefront? {
            get async {
                await MainActor.run {
                    SKPaymentQueue.default().storefront?.asBotsiStorefront
                }
            }
        }

        static var updates: AsyncStream<BotsiStorefront> {
            AsyncStream<BotsiStorefront> { continuation in
                #if os(visionOS)
                    continuation.finish()
                #else
                    Task<Void, Never> {
                        NotificationCenter.default.addObserver(
                            forName: Notification.Name.SKStorefrontCountryCodeDidChange,
                            object: nil,
                            queue: nil
                        ) { _ in
                            if let storefront = SKPaymentQueue.default().storefront {
                                log.verbose("Notifications SKStorefrontCountryCodeDidChange: value is \(storefront)")
                                continuation.yield(storefront.asBotsiStorefront)
                            } else {
                                log.warn("Notifications SKStorefrontCountryCodeDidChange: value is nil")
                            }
                        }
                    }
                #endif
            }
        }
    }
}
