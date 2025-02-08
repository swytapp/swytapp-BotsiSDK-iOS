//
//  BotsiPaywall.ProductReference.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 11.05.2023
//

import Foundation

extension BotsiPaywall {
    struct ProductReference: Sendable, Hashable {
        let botsiProductId: String
        let vendorId: String
        let promotionalOfferId: String?
        let winBackOfferId: String?
    }
}

extension BotsiPaywall.ProductReference: CustomStringConvertible {
    public var description: String {
        "(vendorId: \(vendorId), botsiProductId: \(botsiProductId), promotionalOfferId: \(promotionalOfferId ?? "nil")))"
    }
}

extension BotsiPaywall.ProductReference: Codable {
    enum CodingKeys: String, CodingKey {
        case vendorId = "vendor_product_id"
        case botsiProductId = "botsi_product_id"
        case promotionalOfferEligibility = "promotional_offer_eligibility"
        case promotionalOfferId = "promotional_offer_id"
        case winBackOfferId = "win_back_offer_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        vendorId = try container.decode(String.self, forKey: .vendorId)
        botsiProductId = try container.decode(String.self, forKey: .botsiProductId)
        if (try? container.decode(Bool.self, forKey: .promotionalOfferEligibility)) ?? true {
            promotionalOfferId = try container.decodeIfPresent(String.self, forKey: .promotionalOfferId)
        } else {
            promotionalOfferId = nil
        }

        winBackOfferId = try container.decodeIfPresent(String.self, forKey: .winBackOfferId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(vendorId, forKey: .vendorId)
        try container.encode(botsiProductId, forKey: .botsiProductId)
        try container.encodeIfPresent(promotionalOfferId, forKey: .promotionalOfferId)
        try container.encodeIfPresent(winBackOfferId, forKey: .winBackOfferId)
    }
}
