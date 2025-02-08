//
//  Botsi+CodeRedemptionSheet.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import StoreKit

private let log = Log.default

extension Botsi {
    /// Call this method to have StoreKit present a sheet enabling the user to redeem codes provided by your app.
    public nonisolated static func presentCodeRedemptionSheet() {
        Task.detached {
            let stamp = Log.stamp
            let name = MethodName.presentCodeRedemptionSheet
            var error: String?

            await Botsi.trackSystemEvent(BotsiSDKMethodRequestParameters(methodName: name, stamp: stamp))

            #if (os(iOS) || os(visionOS)) && !targetEnvironment(macCatalyst)
                if #available(iOS 14.0, visionOS 1.0, *) {
                    SKPaymentQueue.default().presentCodeRedemptionSheet()
                } else {
                    error = "Presenting code redemption sheet is available only for iOS 14 and higher."
                }
            #else
                error = "Presenting code redemption sheet is available only for iOS 14 and higher."
            #endif

            if let error { log.error(error) }
            await Botsi.trackSystemEvent(BotsiSDKMethodResponseParameters(methodName: name, stamp: stamp, error: error))
        }
    }
}
