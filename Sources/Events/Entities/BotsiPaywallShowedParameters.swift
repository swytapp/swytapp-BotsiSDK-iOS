//
//  BotsiPaywallShowedParameters.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

struct BotsiPaywallShowedParameters: Sendable {
    let paywallVariationId: String
    let viewConfigurationId: String?
}

extension BotsiPaywallShowedParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case paywallVariationId = "variation_id"
        case viewConfigurationId = "paywall_builder_id"
    }
}
