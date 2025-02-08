//
//  Environment.Meta.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

extension Environment {
    struct Meta: Sendable, Encodable {
        let locale: BotsiLocale
        let timezone: String
        let idfv: String?
        let idfa: String?
        let ipV4Address: String?
        let storefront: BotsiStorefront?
        let webUserAgent: String?
        let envorinment: Environment

        @BotsiActor
        init(includedAnalyticIds: Bool) async {
            locale = System.locale
            timezone = System.timezone
            ipV4Address = Device.ipV4Address
            storefront = await Environment.StoreKit.storefront
            webUserAgent = await Device.webUserAgent
            envorinment = await Environment.instance
            if includedAnalyticIds {
                idfv = await Device.idfv
                idfa = await Device.idfa
            } else {
                idfv = nil
                idfa = nil
            }
        }

        var appTrackingTransparencyStatus: UInt? { Device.appTrackingTransparencyStatus }

        enum CodingKeys: String, CodingKey {
            case appInstallId = "device_id"
            case SDKVersion = "botsi_sdk_version"
            case appBuild = "app_build"
            case appVersion = "app_version"
            case webUserAgent = "user_agent"
            case device
            case locale
            case sysVersion = "os"
            case sysName = "platform"
            case timezone
            case idfa
            case idfv
            case screenWidth = "screen_width"
            case screenHeight = "screen_height"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(envorinment.application.installationIdentifier, forKey: .appInstallId)
            try container.encode(Botsi.SDKVersion, forKey: .SDKVersion)
            try container.encodeIfPresent(envorinment.application.build, forKey: .appBuild)
            try container.encodeIfPresent(envorinment.application.version, forKey: .appVersion)
            try container.encodeIfPresent(webUserAgent, forKey: .webUserAgent)
            try container.encode(Device.name, forKey: .device)
            try container.encode(envorinment.system.version, forKey: .sysVersion)
            try container.encode(envorinment.system.name, forKey: .sysName)
            try container.encodeIfPresent(locale, forKey: .locale)
            try container.encodeIfPresent(timezone, forKey: .timezone)
            try container.encodeIfPresent(idfv, forKey: .idfv)
            try container.encodeIfPresent(idfa, forKey: .idfa)
        }
    }
}
