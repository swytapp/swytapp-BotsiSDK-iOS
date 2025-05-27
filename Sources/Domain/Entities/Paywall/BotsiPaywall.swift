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
    public let sourceProducts: [BotsiSourceProduct]
}

public struct BotsiSourceProduct: Sendable, Codable {
    public let botsiProductId: Int
    public let isConsumable: Bool
    public let sourcePoductId: String
    public let promotionalOfferId: String?
    public let winBackOfferId: String?
}
