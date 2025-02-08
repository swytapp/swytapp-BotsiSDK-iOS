//
//  Backend.Headers.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

extension Backend.Request {
    fileprivate static let authorizationHeaderKey = "Authorization"
    fileprivate static let hashHeaderKey = "botsi-sdk-previous-response-hash"
    fileprivate static let paywallLocaleHeaderKey = "botsi-paywall-locale"
    fileprivate static let viewConfigurationLocaleHeaderKey = "botsi-paywall-builder-locale"
    fileprivate static let visualBuilderVersionHeaderKey = "botsi-paywall-builder-version"
    fileprivate static let visualBuilderConfigurationFormatVersionHeaderKey = "botsi-paywall-builder-config-format-version"
    fileprivate static let segmentIdHeaderKey = "botsi-profile-segment-hash"

    fileprivate static let profileIdHeaderKey = "botsi-sdk-profile-id"
    fileprivate static let sdkVersionHeaderKey = "botsi-sdk-version"
    fileprivate static let sdkPlatformHeaderKey = "botsi-sdk-platform"
    fileprivate static let sdkStoreHeaderKey = "botsi-sdk-store"
    fileprivate static let sessionIDHeaderKey = "botsi-sdk-session"
    fileprivate static let appVersionHeaderKey = "botsi-app-version"

    fileprivate static let isSandboxHeaderKey = "botsi-sdk-sandbox-mode-enabled"
    fileprivate static let isObserveModeHeaderKey = "botsi-sdk-observer-mode-enabled"
    fileprivate static let storeKit2EnabledHeaderKey = "botsi-sdk-storekit2-enabled"
    fileprivate static let appInstallIdHeaderKey = "botsi-sdk-device-id"
    fileprivate static let crossSDKVersionHeaderKey = "botsi-sdk-crossplatform-version"
    fileprivate static let crossSDKPlatformHeaderKey = "botsi-sdk-crossplatform-name"

    static func globalHeaders(_ configuration: BotsiConfiguration, _ envorinment: Environment) -> HTTPHeaders {
        var headers = [
            authorizationHeaderKey: "Api-Key \(configuration.apiKey)",
            sdkVersionHeaderKey: Botsi.SDKVersion,
            sdkPlatformHeaderKey: envorinment.system.name,
            sdkStoreHeaderKey: Environment.StoreKit.name,
            sessionIDHeaderKey: envorinment.sessionIdentifier,
            appInstallIdHeaderKey: envorinment.application.installationIdentifier,
            isObserveModeHeaderKey: configuration.observerMode ? "true" : "false",
            storeKit2EnabledHeaderKey:  Environment.StoreKit.storeKit2Enabled ? "enabled" : "unavailable",
        ]

        if let ver = envorinment.application.version {
            headers[appVersionHeaderKey] = ver
        }

        if let crossPlatformSDK = configuration.crossPlatformSDK {
            headers[crossSDKPlatformHeaderKey] = crossPlatformSDK.name
            headers[crossSDKVersionHeaderKey] = crossPlatformSDK.version
        }

        return headers
    }
}

extension Backend.Response {
    fileprivate static let hashHeaderKey = "x-response-hash"
    fileprivate static let requestIdHeaderKey = "request-id"
}

extension HTTPHeaders {
    func setPaywallLocale(_ locale: BotsiLocale?) -> Self {
        updateOrRemoveValue(locale?.id, forKey: Backend.Request.paywallLocaleHeaderKey)
    }

    func setViewConfigurationLocale(_ locale: BotsiLocale?) -> Self {
        updateOrRemoveValue(locale?.id, forKey: Backend.Request.viewConfigurationLocaleHeaderKey)
    }

    func setVisualBuilderVersion(_ version: String?) -> Self {
        updateOrRemoveValue(version, forKey: Backend.Request.visualBuilderVersionHeaderKey)
    }

    func setVisualBuilderConfigurationFormatVersion(_ version: String?) -> Self {
        updateOrRemoveValue(version, forKey: Backend.Request.visualBuilderConfigurationFormatVersionHeaderKey)
    }

    func setSegmentId(_ id: String?) -> Self {
        updateOrRemoveValue(id, forKey: Backend.Request.segmentIdHeaderKey)
    }

    func setBackendResponseHash(_ hash: String?) -> Self {
        updateOrRemoveValue(hash, forKey: Backend.Request.hashHeaderKey)
    }

    func setBackendProfileId(_ profileId: String?) -> Self {
        updateOrRemoveValue(profileId, forKey: Backend.Request.profileIdHeaderKey)
    }

    private func updateOrRemoveValue(_ value: String?, forKey key: String) -> Self {
        var headers = self
        if let value {
            headers.updateValue(value, forKey: key)
        } else {
            headers.removeValue(forKey: key)
        }
        return headers
    }

    func hasSameBackendResponseHash(_ responseHeaders: HTTPHeaders) -> Bool {
        guard let requestHash = self[Backend.Request.hashHeaderKey],
              let responseHash = responseHeaders.getBackendResponseHash(),
              requestHash == responseHash
        else { return false }
        return true
    }
}

extension HTTPHeaders {
    func getBackendResponseHash() -> String? {
        value(forHTTPHeaderField: Backend.Response.hashHeaderKey)
    }

    func getBackendRequestId() -> String? {
        value(forHTTPHeaderField: Backend.Response.requestIdHeaderKey)
    }
}
