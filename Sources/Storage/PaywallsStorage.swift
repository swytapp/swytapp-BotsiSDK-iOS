//
//  PaywallsStorage.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 22.10.2022.
//

import Foundation

private let log = Log.storage

private extension BotsiPaywall {
    var localeOrDefault: BotsiLocale {
        var remoteConfigLocale = remoteConfig?.botsiLocale
        if let locale = remoteConfigLocale, locale.equalLanguageCode(.defaultPaywallLocale) {
            remoteConfigLocale = nil
        }
        var viewConfigurationLocale = viewConfiguration?.responseLocale
        if let locale = viewConfigurationLocale, locale.equalLanguageCode(.defaultPaywallLocale) {
            viewConfigurationLocale = nil
        }

        return switch (remoteConfigLocale, viewConfigurationLocale) {
        case (.none, .none): .defaultPaywallLocale
        case let (.some(locale), _),
             let (_, .some(locale)): locale
        }
    }

    func equalLanguageCode(_ paywall: BotsiPaywall) -> Bool {
        localeOrDefault.equalLanguageCode(paywall.localeOrDefault)
    }
}

@BotsiActor
final class PaywallsStorage: Sendable {
    private enum Constants {
        static let paywallsStorageKey = "BotsiSDK_Cached_Purchase_Containers"
        static let paywallsStorageVersionKey = "BotsiSDK_Cached_Purchase_Containers_Version"
        static let currentPaywallsStorageVersion = 2
    }

    private static let userDefaults = Storage.userDefaults

    private static var paywallByPlacementId: [String: VH<BotsiPaywall>] = {
        guard userDefaults.integer(forKey: Constants.paywallsStorageVersionKey) == Constants.currentPaywallsStorageVersion else {
            return [:]
        }
        do {
            return try userDefaults.getJSON([VH<BotsiPaywall>].self, forKey: Constants.paywallsStorageKey)?.asPaywallByPlacementId ?? [:]
        } catch {
            log.error(error.localizedDescription)
            return [:]
        }
    }()

    func getPaywallByLocale(_ locale: BotsiLocale, orDefaultLocale: Bool, withPlacementId placementId: String) -> VH<BotsiPaywall>? {
        guard let paywall = Self.paywallByPlacementId[placementId] else { return nil }
        let paywallLocale = paywall.value.localeOrDefault
        return if paywallLocale.equalLanguageCode(locale) {
            paywall
        } else if orDefaultLocale, paywallLocale.equalLanguageCode(.defaultPaywallLocale) {
            paywall
        } else {
            nil
        }
    }

    private func getNewerPaywall(than paywall: BotsiPaywall) -> BotsiPaywall? {
        guard let cached: BotsiPaywall = Self.paywallByPlacementId[paywall.placementId]?.value,
              cached.equalLanguageCode(paywall) else { return nil }
        return paywall.version >= cached.version ? nil : cached
    }

    func savedPaywallChosen(_ chosen: BotsiPaywallChosen) -> BotsiPaywallChosen {
        let paywall = chosen.value
        if let newer = getNewerPaywall(than: paywall) { return BotsiPaywallChosen(value: newer, kind: .restore) }

        Self.paywallByPlacementId[paywall.placementId] = VH(paywall, time: Date())

        let paywalls = Array(Self.paywallByPlacementId.values)

        guard !paywalls.isEmpty else {
            Self.clear()
            return chosen
        }

        do {
            Self.userDefaults.set(Constants.currentPaywallsStorageVersion, forKey: Constants.paywallsStorageVersionKey)
            try Self.userDefaults.setJSON(paywalls, forKey: Constants.paywallsStorageKey)
            log.debug("Saving paywalls success.")
        } catch {
            log.error("Saving paywalls fail. \(error.localizedDescription)")
        }

        return chosen
    }

    static func clear() {
        paywallByPlacementId = [:]
        userDefaults.removeObject(forKey: Constants.paywallsStorageKey)
        log.debug("Clear paywalls.")
    }
}
