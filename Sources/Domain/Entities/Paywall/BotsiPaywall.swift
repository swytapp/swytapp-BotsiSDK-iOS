//
//  BotsiPaywall.swift
//  Botsi
//
//  Created by Vladyslav on 22.03.2025.
//

import Foundation

public struct BotsiPaywall: Sendable, Codable {
    public let placementId: String?
    public let id: Int
    public let name: String
    public let remoteConfigs: String?
    public let revision: Int
    public let abTestId: Int?
    public let sourceProducts: [BotsiSourceProduct]
    
    private enum CodingKeys: String, CodingKey {
        case placementId
        case id
        case name
        case remoteConfigs
        case revision
        case abTestId
        case sourceProducts
    }
    
    public init(
        placementId: String? = nil,
        id: Int,
        name: String,
        remoteConfigs: String? = nil,
        revision: Int,
        abTestId: Int? = nil,
        sourceProducts: [BotsiSourceProduct]
    ) {
        self.placementId = placementId
        self.id = id
        self.name = name
        self.remoteConfigs = remoteConfigs
        self.revision = revision
        self.abTestId = abTestId
        self.sourceProducts = sourceProducts
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        placementId = try container.decodeIfPresent(String.self, forKey: .placementId)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        remoteConfigs = try container.decodeIfPresent(String.self, forKey: .remoteConfigs)
        revision = try container.decode(Int.self, forKey: .revision)
        abTestId = try container.decodeIfPresent(Int.self, forKey: .abTestId)
        sourceProducts = try container.decode([BotsiSourceProduct].self, forKey: .sourceProducts)
    }
}

public struct BotsiSourceProduct: Sendable, Codable {
    public let botsiProductId: Int
    public let isConsumable: Bool
    public let sourcePoductId: String
    public let promotionalOfferId: String?
    public let winBackOfferId: String?
    
    public init(
        botsiProductId: Int,
        isConsumable: Bool,
        sourcePoductId: String,
        promotionalOfferId: String? = nil,
        winBackOfferId: String? = nil
    ) {
        self.botsiProductId = botsiProductId
        self.isConsumable = isConsumable
        self.sourcePoductId = sourcePoductId
        self.promotionalOfferId = promotionalOfferId
        self.winBackOfferId = winBackOfferId
    }
}
