//
//  BotsiPaywallVariationAssignedParameters.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

struct BotsiPaywallVariationAssignedParameters: Sendable {
    let paywallVariationId: String
    let viewConfigurationId: String?
    let placementAudienceVersionId: String
}

extension BotsiPaywallVariationAssignedParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case paywallVariationId = "variation_id"
        case viewConfigurationId = "paywall_builder_id"
        case placementAudienceVersionId = "placement_audience_version_id"
    }
}
