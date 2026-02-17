//
//  BotsiPaywall.swift
//  Botsi
//
//  Created by Vladyslav on 22.03.2025.
//

import Foundation

public struct BotsiPaywall: Sendable, Codable {
    public var placementId: String
    public let id: Int
    public let name: String
    public let remoteConfigs: String?
    public let revision: Int
    public let abTestId: Int?
    public let aiPricingModelId: Int?
    public let isExperiment: Bool?
    public let sourceProducts: [BotsiSourceProduct]
}

public struct BotsiSourceProduct: Sendable, Codable {
    public let botsiProductId: Int
    public let isConsumable: Bool
    public let sourceProductId: String
    public let promotionalOfferId: String?
    public let winBackOfferId: String?

    enum CodingKeys: String, CodingKey {
        case botsiProductId
        case isConsumable
        case sourceProductId = "sourcePoductId"
        case promotionalOfferId
        case winBackOfferId
    }
}
