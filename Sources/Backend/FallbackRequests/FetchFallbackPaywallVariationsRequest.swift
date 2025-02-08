//
//  FetchFallbackPaywallRequest.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchFallbackPaywallVariationsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = BotsiPaywallChosen

    let endpoint: HTTPEndpoint
    let profileId: String
    let stamp = Log.stamp

    let cached: BotsiPaywall?
    let queryItems: QueryItems

    func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?
    ) throws -> Response {
        try Self.decodeDataResponse(
            response,
            withConfiguration: configuration,
            withProfileId: profileId,
            withCachedPaywall: cached
        )
    }

    init(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: BotsiLocale,
        cached: BotsiPaywall?,
        disableServerCache: Bool
    ) {
        self.profileId = profileId
        self.cached = cached
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/app_store/\(locale.languageCode.lowercased())/\(BotsiViewConfiguration.builderVersion)/fallback.json"
        )
        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

protocol FetchFallbackPaywallVariationsExecutor: BackendExecutor {
    func fetchFallbackPaywallVariations(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: BotsiLocale,
        cached: BotsiPaywall?,
        disableServerCache: Bool
    ) async throws -> BotsiPaywallChosen
}

private extension FetchFallbackPaywallVariationsExecutor {
    @inline(__always)
    func performFetchFallbackPaywallVariationsRequest(
        requestName: APIRequestName,
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: BotsiLocale,
        cached: BotsiPaywall?,
        disableServerCache: Bool
    ) async throws -> BotsiPaywallChosen {
        let request = FetchFallbackPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            cached: cached,
            disableServerCache: disableServerCache
        )

        do {
            let response = try await perform(
                request,
                requestName: requestName,
                logParams: [
                    "api_prefix": apiKeyPrefix,
                    "placement_id": placementId,
                    "language_code": locale.languageCode,
                    "builder_version": BotsiViewConfiguration.builderVersion,
                    "builder_config_format_version": BotsiViewConfiguration.formatVersion,
                    "disable_server_cache": disableServerCache,
                ]
            )
            return response.body
        } catch {
            guard (error as? HTTPError)?.statusCode == 404,
                  !locale.equalLanguageCode(BotsiLocale.defaultPaywallLocale) else {
                throw error
            }

            return try await performFetchFallbackPaywallVariationsRequest(
                requestName: requestName,
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                locale: .defaultPaywallLocale,
                cached: cached,
                disableServerCache: disableServerCache
            )
        }
    }
}

extension Backend.FallbackExecutor: FetchFallbackPaywallVariationsExecutor {
    func fetchFallbackPaywallVariations(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: BotsiLocale,
        cached: BotsiPaywall?,
        disableServerCache: Bool
    ) async throws -> BotsiPaywallChosen {
        try await performFetchFallbackPaywallVariationsRequest(
            requestName: .fetchFallbackPaywallVariations,
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            cached: cached,
            disableServerCache: disableServerCache
        )
    }
}

extension Backend.ConfigsExecutor: FetchFallbackPaywallVariationsExecutor {
    func fetchFallbackPaywallVariations(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: BotsiLocale,
        cached: BotsiPaywall?,
        disableServerCache: Bool
    ) async throws -> BotsiPaywallChosen {
        try await performFetchFallbackPaywallVariationsRequest(
            requestName: .fetchUntargetedPaywallVariations,
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            cached: cached,
            disableServerCache: disableServerCache
        )
    }
}
