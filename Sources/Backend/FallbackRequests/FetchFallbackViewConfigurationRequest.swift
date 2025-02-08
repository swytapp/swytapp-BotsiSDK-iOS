//
//  FetchFallbackViewConfigurationRequest.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

struct FetchFallbackViewConfigurationRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<BotsiViewSource>

    let endpoint: HTTPEndpoint
    let queryItems: QueryItems
    let stamp = Log.stamp

    init(apiKeyPrefix: String, paywallInstanceIdentity: String, locale: BotsiLocale, disableServerCache: Bool) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall-builder/\(paywallInstanceIdentity)/\(BotsiViewConfiguration.builderVersion)/\(locale.languageCode)/fallback.json"
        )

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension Backend.FallbackExecutor {
    func fetchFallbackViewConfiguration(
        apiKeyPrefix: String,
        paywallInstanceIdentity: String,
        locale: BotsiLocale,
        disableServerCache: Bool
    ) async throws -> BotsiViewSource {
        let request = FetchFallbackViewConfigurationRequest(
            apiKeyPrefix: apiKeyPrefix,
            paywallInstanceIdentity: paywallInstanceIdentity,
            locale: locale,
            disableServerCache: disableServerCache
        )

        do {
            let response = try await perform(
                request,
                requestName: .fetchFallbackViewConfiguration,
                logParams: [
                    "api_prefix": apiKeyPrefix,
                    "paywall_instance_id": paywallInstanceIdentity,
                    "builder_version": BotsiViewConfiguration.builderVersion,
                    "builder_config_format_version": BotsiViewConfiguration.formatVersion,
                    "language_code": locale.languageCode,
                    "disable_server_cache": disableServerCache,
                ]
            )

            return response.body.value
        } catch {
            guard (error as? HTTPError)?.statusCode == 404,
                  !locale.equalLanguageCode(BotsiLocale.defaultPaywallLocale) else {
                throw error
            }
            return try await fetchFallbackViewConfiguration(
                apiKeyPrefix: apiKeyPrefix,
                paywallInstanceIdentity: paywallInstanceIdentity,
                locale: .defaultPaywallLocale,
                disableServerCache: disableServerCache
            )
        }
    }
}
