//
//  SK2Storefront.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
typealias SK2Storefront = Storefront

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Storefront {
    var asBotsiStorefront: BotsiStorefront {
        .init(id: id, countryCode: countryCode)
    }
}

private let log = Log.storeFront

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension BotsiStorefront {
    enum StoreKit2 {
        static var current: BotsiStorefront? {
            get async {
                await SK2Storefront.current?.asBotsiStorefront
            }
        }

        static var updates: AsyncStream<BotsiStorefront> {
            AsyncStream<BotsiStorefront> { continuation in
                Task {
                    for await storefront in SK2Storefront.updates {
                        log.verbose("StoreKit2 Storefront.updates new value: \(storefront)")
                        continuation.yield(storefront.asBotsiStorefront)
                    }
                    continuation.finish()
                }
            }
        }
    }
}
