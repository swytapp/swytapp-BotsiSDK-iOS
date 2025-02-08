//
//  FetchViewConfigurationRequest.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

struct FetchViewConfigurationRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<BotsiViewSource>

    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    init(apiKeyPrefix: String, paywallVariationId: String, locale: BotsiLocale, md5Hash: String, disableServerCache: Bool) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall-builder/\(paywallVariationId)/\(md5Hash)/"
        )

        headers = HTTPHeaders()
            .setViewConfigurationLocale(locale)
            .setVisualBuilderVersion(BotsiViewConfiguration.builderVersion)
            .setVisualBuilderConfigurationFormatVersion(BotsiViewConfiguration.formatVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension Backend.MainExecutor {
    func fetchViewConfiguration(
        apiKeyPrefix: String,
        paywallVariationId: String,
        locale: BotsiLocale,
        disableServerCache: Bool
    ) async throws -> BotsiViewSource {
        let md5Hash = "{\"builder_version\":\"\(BotsiViewConfiguration.builderVersion)\",\"locale\":\"\(locale.id.lowercased())\"}".md5.hexString

        let request = FetchViewConfigurationRequest(
            apiKeyPrefix: apiKeyPrefix,
            paywallVariationId: paywallVariationId,
            locale: locale,
            md5Hash: md5Hash,
            disableServerCache: disableServerCache
        )

        let response = try await perform(
            request,
            requestName: .fetchViewConfiguration,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "variation_id": paywallVariationId,
                "locale": locale,
                "builder_version": BotsiViewConfiguration.builderVersion,
                "builder_config_format_version": BotsiViewConfiguration.formatVersion,
                "md5": md5Hash,
                "disable_server_cache": disableServerCache,
            ]
        )

        return response.body.value
    }
}
