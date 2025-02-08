//
//  Botsi+UntargetedPaywalls.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 12.08.2024
//

import Foundation

extension Botsi {
    /// This method enables you to retrieve the paywall from the Default Audience without having to wait for the Botsi SDK to send all the user information required for segmentation to the server.
    ///
    /// - Parameters:
    ///   - placementId: The identifier of the desired paywall. This is the value you specified when you created the paywall in the Botsi Dashboard.
    ///   - locale: The identifier of the paywall [localization](https://docs.adapty.io/docs/paywall#localizations).
    ///             This parameter is expected to be a language code composed of one or more subtags separated by the "-" character. The first subtag is for the language, the second one is for the region (The support for regions will be added later).
    ///             Example: "en" means English, "en-US" represents US English.
    ///             If the parameter is omitted, the paywall will be returned in the default locale.
    ///   - fetchPolicy: by default SDK will try to load data from server and will return cached data in case of failure. Otherwise use `.returnCacheDataElseLoad` to return cached data if it exists.
    /// - Returns: The ``BotsiPaywall`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
    /// - Throws: An ``BotsiError`` object
    public nonisolated static func getPaywallForDefaultAudience(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: BotsiPaywall.FetchPolicy = .default
    ) async throws -> BotsiPaywall {
        let locale = locale.map { BotsiLocale(id: $0) } ?? .defaultPaywallLocale

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
        ]

        return try await withActivatedSDK(methodName: .getPaywallForDefaultAudience, logParams: logParams) { sdk in
            let paywall = try await sdk.getPaywallForDefaultAudience(
                placementId,
                locale,
                fetchPolicy
            )
            
            Botsi.sendImageUrlsToObserver(paywall)
            return paywall
        }
    }

    private func getPaywallForDefaultAudience(
        _ placementId: String,
        _ locale: BotsiLocale,
        _ fetchPolicy: BotsiPaywall.FetchPolicy
    ) async throws -> BotsiPaywall {
        let manager = profileManager
        let profileId = manager?.profileId ?? profileStorage.profileId
        let session = httpConfigsSession

        let fetchTask = Task {
            try await fetchFallbackPaywall(
                profileId,
                placementId,
                locale,
                session
            )
        }

        let cached = manager?
            .paywallsStorage
            .getPaywallByLocale(locale, orDefaultLocale: true, withPlacementId: placementId)?
            .withFetchPolicy(fetchPolicy)?
            .value

        let paywall =
            if let cached {
                cached
            } else {
                try await fetchTask.value
            }

        return paywall
    }
}
