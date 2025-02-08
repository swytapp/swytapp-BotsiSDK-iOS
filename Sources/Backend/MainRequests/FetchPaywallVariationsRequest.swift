//
//  FetchPaywallVariationsRequest.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchPaywallVariationsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = BotsiPaywallChosen

    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let stamp = Log.stamp

    let profileId: String
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

    init(apiKeyPrefix: String, profileId: String, placementId: String, locale: BotsiLocale, md5Hash: String, segmentId: String, cached: BotsiPaywall?, disableServerCache: Bool) {
        self.profileId = profileId
        self.cached = cached

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/"
        )

        headers = HTTPHeaders()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
            .setVisualBuilderVersion(BotsiViewConfiguration.builderVersion)
            .setVisualBuilderConfigurationFormatVersion(BotsiViewConfiguration.formatVersion)
            .setSegmentId(segmentId)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension HTTPRequestWithDecodableResponse where ResponseBody == BotsiPaywallChosen {
    @inlinable
    static func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?,
        withProfileId profileId: String,
        withCachedPaywall cached: BotsiPaywall?
    ) throws -> HTTPResponse<BotsiPaywallChosen> {
        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)
        jsonDecoder.setProfileId(profileId)

        let version: Int64 = try jsonDecoder.decode(
            Backend.Response.ValueOfMeta<BotsiPaywallChosen.Meta>.self,
            responseBody: response.body
        ).meta.version

        let body: BotsiPaywallChosen =
            if let cached, cached.version > version {
                BotsiPaywallChosen(
                    value: cached,
                    kind: .restore
                )
            } else {
                try jsonDecoder.decode(
                    Backend.Response.ValueOfData<BotsiPaywallChosen>.self,
                    responseBody: response.body
                ).value.replaceBotsiPaywall(version: version)
            }

        return response.replaceBody(body)
    }
}

extension Backend.MainExecutor {
    func fetchPaywallVariations(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: BotsiLocale,
        segmentId: String,
        cached: BotsiPaywall?,
        disableServerCache: Bool
    ) async throws -> BotsiPaywallChosen {
        let md5Hash = "{\"builder_version\":\"\(BotsiViewConfiguration.builderVersion)\",\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\",\"store\":\"app_store\"}".md5.hexString

        let request = FetchPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            md5Hash: md5Hash,
            segmentId: segmentId,
            cached: cached,
            disableServerCache: disableServerCache
        )

        let response = try await perform(
            request,
            requestName: .fetchPaywallVariations,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "locale": locale,
                "segment_id": segmentId,
                "builder_version": BotsiViewConfiguration.builderVersion,
                "builder_config_format_version": BotsiViewConfiguration.formatVersion,
                "md5": md5Hash,
                "disable_server_cache": disableServerCache,
            ]
        )

        return response.body
    }
}
