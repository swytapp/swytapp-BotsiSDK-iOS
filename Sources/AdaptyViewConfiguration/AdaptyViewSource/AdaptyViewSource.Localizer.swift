//
//  BotsiViewSource.Localizer.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension BotsiViewSource {
    final class Localizer: @unchecked Sendable {
        let id = UUID()
        let localization: Localization?
        let source: BotsiViewSource
        let locale: BotsiLocale
        var elementIds = Set<String>()

        init(source: BotsiViewSource, withLocale: BotsiLocale) {
            self.source = source
            self.localization = source.getLocalization(withLocale)
            self.locale = self.localization?.id ?? withLocale
        }
    }
}

extension BotsiViewSource.Localizer: Hashable {
    static func == (lhs: BotsiViewSource.Localizer, rhs: BotsiViewSource.Localizer) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension BotsiViewSource.Localizer {
    func localize() throws -> BotsiViewConfiguration {
        elementIds.removeAll()
        return try .init(
            id: source.id,
            locale: locale.id,
            isRightToLeft: localization?.isRightToLeft ?? false,
            templateId: source.templateId,
            screen: screen(source.defaultScreen),
            bottomSheets: source.screens.mapValues(bottomSheet),
            templateRevision: source.templateRevision,
            selectedProducts: source.selectedProducts
        )
    }
}

package enum BotsiLocalizerError: Swift.Error {
    case notFoundAsset(String)
    case wrongTypeAsset(String)
    case unknownReference(String)
    case referenceCycle(String)
}
