//
//  Botsi+Paywalls.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 01.11.2023
//

import Foundation

private let log = Log.default

extension Botsi {

    /// Botsi allows you remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without app releases.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
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
    public nonisolated static func getPaywall(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: BotsiPaywall.FetchPolicy = .default,
        loadTimeout: TimeInterval? = nil
    ) async throws -> BotsiPaywall {
        let loadTimeout = (loadTimeout ?? .defaultLoadPaywallTimeout).allowedLoadPaywallTimeout
        let locale = locale.map { BotsiLocale(id: $0) } ?? .defaultPaywallLocale

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
            "load_timeout": loadTimeout.asMilliseconds,
        ]

        return try await withActivatedSDK(methodName: .getPaywall, logParams: logParams) { sdk in
            let paywall = try await sdk.getPaywall(
                placementId,
                locale,
                fetchPolicy,
                loadTimeout
            )
            Botsi.sendImageUrlsToObserver(paywall)

            return paywall
        }
    }

    private func getPaywall(
        _ placementId: String,
        _ locale: BotsiLocale,
        _ fetchPolicy: BotsiPaywall.FetchPolicy,
        _ loadTimeout: TaskDuration
    ) async throws -> BotsiPaywall {
        let profileId = profileStorage.profileId

        do {
            return try await withThrowingTimeout(loadTimeout - .milliseconds(500)) {
                try await self.fetchPaywall(
                    profileId,
                    placementId,
                    locale,
                    fetchPolicy
                )
            }
        } catch let error where error.canUseFallbackServer {
            return try await fetchFallbackPaywall(
                profileId,
                placementId,
                locale,
                httpFallbackSession
            )
        } catch {
            guard let chosen = try profileManager(with: profileId).orThrows
                .paywallsStorage
                .getPaywallWithFallback(byPlacementId: placementId, profileId: profileId, locale: locale)
            else {
                throw error.asBotsiError ?? BotsiError.fetchPaywallFailed(unknownError: error)
            }
            Botsi.trackEventIfNeed(chosen)
            return chosen.value
        }
    }

    private func fetchPaywall(
        _ profileId: String,
        _ placementId: String,
        _ locale: BotsiLocale,
        _ fetchPolicy: BotsiPaywall.FetchPolicy
    ) async throws -> BotsiPaywall {
        let manager = try await createdProfileManager
        
        guard manager.profileId == profileId else {
            throw BotsiError.profileWasChanged()
        }

        let fetchTask = Task {
            try await fetchPaywall(
                profileId,
                placementId,
                locale
            )
        }

        let cached = manager
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

    private func fetchPaywall(
        _ profileId: String,
        _ placementId: String,
        _ locale: BotsiLocale
    ) async throws -> BotsiPaywall {
        
        while true {
            let (segmentId, cached, isTestUser): (String, BotsiPaywall?, Bool) = try {
                let manager = try profileManager(with: profileId).orThrows
                return (
                    manager.profile.value.segmentId,
                    manager.paywallsStorage.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: placementId)?.value,
                    manager.profile.value.isTestUser
                )
            }()
            
            do {
                var response = try await httpSession.fetchPaywallVariations(
                    apiKeyPrefix: apiKeyPrefix,
                    profileId: profileId,
                    placementId: placementId,
                    locale: locale,
                    segmentId: segmentId,
                    cached: cached,
                    disableServerCache: isTestUser
                )
                
                if let manager = tryProfileManagerOrNil(with: profileId) {
                    response = manager.paywallsStorage.savedPaywallChosen(response)
                }
                
                Botsi.trackEventIfNeed(response)
                return response.value
                
            } catch {
                guard error.wrongProfileSegmentId,
                      try await updateSegmentId(for: profileId, oldSegmentId: segmentId)
                else {
                    throw error.asBotsiError ?? BotsiError.fetchPaywallFailed(unknownError: error)
                }
            }
        }

        func updateSegmentId(for profileId: String, oldSegmentId: String) async throws -> Bool {
            let manager = try profileManager(with: profileId).orThrows
            guard manager.profile.value.segmentId == oldSegmentId else { return true }
            return await manager.getProfile().segmentId != oldSegmentId
        }
    }

    func fetchFallbackPaywall(
        _ profileId: String,
        _ placementId: String,
        _ locale: BotsiLocale,
        _ session: some FetchFallbackPaywallVariationsExecutor
    ) async throws -> BotsiPaywall {
        let result: BotsiPaywallChosen

        do {
            let (cached, isTestUser): (BotsiPaywall?, Bool) = {
                guard let manager = tryProfileManagerOrNil(with: profileId) else { return (nil, false) }
                return (
                    manager.paywallsStorage.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: placementId)?.value,
                    manager.profile.value.isTestUser
                )
            }()

            var response = try await session.fetchFallbackPaywallVariations(
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                locale: locale,
                cached: cached,
                disableServerCache: isTestUser
            )

            if let manager = tryProfileManagerOrNil(with: profileId) {
                response = manager.paywallsStorage.savedPaywallChosen(response)
            }

            result = response

        } catch {
            let chosen =
                if let manager = tryProfileManagerOrNil(with: profileId) {
                    manager.paywallsStorage.getPaywallWithFallback(byPlacementId: placementId, profileId: profileId, locale: locale)
                } else {
                    Botsi.fallbackPaywalls?.getPaywall(byPlacementId: placementId, profileId: profileId)
                }

            guard let chosen else {
                throw error.asBotsiError ?? BotsiError.fetchPaywallFailed(unknownError: error)
            }

            result = chosen
        }

        Botsi.trackEventIfNeed(result)
        return result.value
    }
}

extension TimeInterval {
    static let defaultLoadPaywallTimeout: TimeInterval = 5.0
    static let minimumLoadPaywallTimeout: TimeInterval = 1.0

    var allowedLoadPaywallTimeout: TaskDuration {
        let minimum: TimeInterval = .minimumLoadPaywallTimeout
        guard self < minimum else { return TaskDuration(self) }
        log.warn("The  paywall load timeout parameter cannot be less than \(minimum)s")
        return TaskDuration(minimum)
    }
}

private extension Error {
    var canUseFallbackServer: Bool {
        let error = unwrapped
        if error is TimeoutError { return true }
        if let httpError = error as? HTTPError { return Backend.canUseFallbackServer(httpError) }
        return false
    }

    var wrongProfileSegmentId: Bool {
        let error = unwrapped
        if let httpError = error as? HTTPError { return Backend.wrongProfileSegmentId(httpError) }
        return false
    }
}
