//
//  LazyLocalisedProductText.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 02.05.2024
//
//

import Foundation

extension BotsiViewConfiguration {
    package struct LazyLocalisedProductText: Sendable, Hashable {
        package let botsiProductId: String
        private let suffix: String?
        private let localizer: BotsiViewSource.Localizer
        private let defaultTextAttributes: BotsiViewSource.TextAttributes?

        init(
            botsiProductId: String,
            suffix: String?,
            localizer: BotsiViewSource.Localizer,
            defaultTextAttributes: BotsiViewSource.TextAttributes?
        ) {
            self.botsiProductId = botsiProductId
            self.suffix = suffix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
        }

        package func richText(
            byPaymentMode mode: BotsiSubscriptionOffer.PaymentMode = .unknown
        ) -> RichText {
            localizer.richText(
                botsiProductId: botsiProductId,
                byPaymentMode: mode,
                suffix: suffix,
                defaultTextAttributes: defaultTextAttributes
            )
        }
    }

    package struct LazyLocalisedUnknownProductText: Sendable, Hashable {
        package let productGroupId: String
        private let suffix: String?
        private let localizer: BotsiViewSource.Localizer
        private let defaultTextAttributes: BotsiViewSource.TextAttributes?

        init(
            productGroupId: String,
            suffix: String?,
            localizer: BotsiViewSource.Localizer,
            defaultTextAttributes: BotsiViewSource.TextAttributes?
        ) {
            self.productGroupId = productGroupId
            self.suffix = suffix
            self.localizer = localizer
            self.defaultTextAttributes = defaultTextAttributes
        }

        package func richText() -> RichText {
            localizer.richText(
                stringId: BotsiViewSource.StringId.Product.calculate(
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) ?? .empty
        }

        package func richText(
            botsiProductId: String,
            byPaymentMode mode: BotsiSubscriptionOffer.PaymentMode = .unknown
        ) -> RichText {
            localizer.richText(
                botsiProductId: botsiProductId,
                byPaymentMode: mode,
                suffix: suffix,
                defaultTextAttributes: defaultTextAttributes
            )
        }
    }
}

private extension BotsiViewSource.Localizer {
    func richText(
        botsiProductId: String,
        byPaymentMode mode: BotsiSubscriptionOffer.PaymentMode = .unknown,
        suffix: String?,
        defaultTextAttributes: BotsiViewSource.TextAttributes?
    ) -> BotsiViewConfiguration.RichText {
        if
            let value = richText(
                stringId: BotsiViewSource.StringId.Product.calculate(
                    botsiProductId: botsiProductId,
                    byPaymentMode: mode,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else if
            mode != .unknown,
            let value = richText(
                stringId: BotsiViewSource.StringId.Product.calculate(
                    botsiProductId: botsiProductId,
                    byPaymentMode: .unknown,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else if
            let value = richText(
                stringId: BotsiViewSource.StringId.Product.calculate(
                    byPaymentMode: mode,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else if
            mode != .unknown,
            let value = richText(
                stringId: BotsiViewSource.StringId.Product.calculate(
                    byPaymentMode: .unknown,
                    suffix: suffix
                ),
                defaultTextAttributes: defaultTextAttributes
            ) {
            value
        } else {
            .empty
        }
    }
}
