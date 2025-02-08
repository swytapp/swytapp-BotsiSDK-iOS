//
//  BotsiViewSource+getLocalization.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 29.03.2024
//
//

import Foundation

extension BotsiViewSource {
    func extractLocale()  throws -> BotsiViewConfiguration {
        try extractLocale(responseLocale)
    }

    func extractLocale(_ locale: BotsiLocale) throws -> BotsiViewConfiguration {
        try Localizer(source: self, withLocale: locale).localize()
    }

    func getLocalization(_ locale: BotsiLocale) -> Localization? {
        if let value = localizations[locale] {
            if defaultLocalization?.id == value.id {
                value
            } else {
                value.addDefault(localization: defaultLocalization)
            }
        } else {
            defaultLocalization
        }
    }
}

private extension BotsiViewSource.Localization {
    func addDefault(localization: Self?) -> Self {
        guard let localization else { return self }

        var strings = self.strings ?? [:]
        if let other = localization.strings {
            strings = strings.merging(other, uniquingKeysWith: { current, _ in current })
        }

        var assets = self.assets ?? [:]
        if let other = localization.assets {
            assets = assets.merging(other, uniquingKeysWith: { current, _ in current })
        }

        return .init(
            id: id,
            isRightToLeft: isRightToLeft ?? localization.isRightToLeft,
            strings: strings.isEmpty ? nil : strings,
            assets: assets.isEmpty ? nil : assets
        )
    }
}
