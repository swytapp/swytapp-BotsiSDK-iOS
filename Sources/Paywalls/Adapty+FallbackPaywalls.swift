//
//  Botsi+FallbackPaywalls.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

extension Botsi {
    static var fallbackPaywalls: FallbackPaywalls?

    /// To set fallback paywalls, use this method. You should pass exactly the same payload you're getting from Botsi backend. You can copy it from Botsi Dashboard.
    ///
    /// Botsi allows you to provide fallback paywalls that will be used when a user opens the app for the first time and there's no internet connection. Or in the rare case when Botsi backend is down and there's no cache on the device.
    ///
    /// Read more on the [Botsi Documentation](https://adapty.io/docs/ios-use-fallback-paywalls)
    ///
    /// - Parameters:
    ///   - fileURL:
    /// - Throws: An ``BotsiError`` object
    public nonisolated static func setFallbackPaywalls(fileURL url: URL) async throws {
        try await withoutSDK(
            methodName: .setFallbackPaywalls
        ) { @BotsiActor in
            do {
                Botsi.fallbackPaywalls = try FallbackPaywalls(fileURL: url)
            } catch {
                throw error.asBotsiError ?? .decodingFallbackFailed(unknownError: error)
            }
        }
    }
}

private let log = Log.fallbackPaywalls

extension PaywallsStorage {
    func getPaywallWithFallback(byPlacementId placementId: String, profileId: String, locale: BotsiLocale) -> BotsiPaywallChosen? {
        let cache = getPaywallByLocale(locale, orDefaultLocale: true, withPlacementId: placementId).map {
            BotsiPaywallChosen(value: $0.value, kind: .restore)
        }

        guard let fallback = Botsi.fallbackPaywalls,
              fallback.contains(placementId: placementId) ?? true
        else {
            return cache
        }

        if let cache, cache.value.version >= fallback.version {
            return cache
        }

        guard let chosen = fallback.getPaywall(byPlacementId: placementId, profileId: profileId)
        else {
            return cache
        }
        log.verbose("return from fallback paywall (placementId: \(placementId))")
        return chosen
    }
}
