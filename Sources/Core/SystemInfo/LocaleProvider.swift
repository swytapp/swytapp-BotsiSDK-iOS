//
//  LocaleProvider.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//

import Foundation

struct BotsiUserLocale {
    let languageCode: String
    let regionCode: String
    let currencyCode: String
    let identifier: String
}

protocol LocaleProviding {
    func getUserLocale() -> BotsiUserLocale
}

final class SystemLocaleProvider: LocaleProviding {
    func getUserLocale() -> BotsiUserLocale {
        let locale = Locale.current
        return BotsiUserLocale(
            languageCode: locale.languageCode ?? "en",
            regionCode: locale.regionCode ?? "US",
            currencyCode: locale.currencyCode ?? "",
            identifier: locale.identifier
        )
    }
}

final class LocaleManager {
    private let provider: LocaleProviding
    
    init(provider: LocaleProviding = SystemLocaleProvider()) {
        self.provider = provider
    }
    
    func fetchUserLocale() -> BotsiUserLocale {
        return provider.getUserLocale()
    }
}
