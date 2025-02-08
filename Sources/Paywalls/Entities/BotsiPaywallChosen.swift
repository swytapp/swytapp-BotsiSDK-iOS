//
//  BotsiPaywallChosen.swift
//
//
//  Created by Aleksei Valiano on 26.03.2024
//
//

import Foundation

struct BotsiPaywallChosen: Sendable {
    var value: BotsiPaywall
    let kind: Kind

    enum Kind: Sendable, Hashable {
        case restore
        case draw(placementAudienceVersionId: String, profileId: String)
    }
}

extension BotsiPaywallChosen: Decodable {
    init(from decoder: Decoder) throws {
        let items = try [BotsiPaywallVariation](from: decoder)
        guard let firstItem = items.first else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Paywalls collection is empty"))
        }

        let profileId = try decoder.userInfo.profileId
        let paywall =
            if items.count == 1 {
                try paywall(from: decoder, index: 0)
            } else {
                try paywall(from: decoder, index: Self.choose(
                    items: items,
                    placementAudienceVersionId: firstItem.placementAudienceVersionId,
                    profileId: profileId
                ))
            }

        self.init(
            value: paywall,
            kind: .draw(
                placementAudienceVersionId: firstItem.placementAudienceVersionId,
                profileId: profileId
            )
        )

        func paywall(from decoder: Decoder, index: Int) throws -> BotsiPaywall {
            struct Empty: Decodable {}

            var array = try decoder.unkeyedContainer()
            while !array.isAtEnd {
                if array.currentIndex == index {
                    return try array.decode(BotsiPaywall.self)
                }
                _ = try array.decode(Empty.self)
            }

            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Paywall with index \(index) not found"))
        }
    }
}

extension BotsiPaywallChosen {
    private struct BotsiPaywallVariation: Sendable, Decodable {
        let placementAudienceVersionId: String
        let variationId: String
        let weight: Int

        enum CodingKeys: String, CodingKey {
            case placementAudienceVersionId = "placement_audience_version_id"
            case variationId = "variation_id"
            case weight

            case attributes
        }

        init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.attributes) {
                container = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
            }

            placementAudienceVersionId = try container.decode(String.self, forKey: .placementAudienceVersionId)
            variationId = try container.decode(String.self, forKey: .variationId)
            weight = try container.decode(Int.self, forKey: .weight)
        }
    }

    private static func choose(
        items: [BotsiPaywallVariation],
        placementAudienceVersionId: String,
        profileId: String
    ) -> Int {
        let data = Data("\(placementAudienceVersionId)-\(profileId)".md5.suffix(8))
        let value: UInt64 = data.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
        var weight = Int(value % 100)

        let sortedItems = items
            .enumerated()
            .sorted(by: { first, second in
                if first.element.weight == second.element.weight {
                    first.element.variationId < second.element.variationId
                } else {
                    first.element.weight < second.element.weight
                }
            })

        let index = sortedItems.firstIndex { item in
            weight -= item.element.weight
            return weight <= 0
        } ?? (items.count - 1)

        return sortedItems[index].offset
    }
}

extension BotsiPaywallChosen {
    struct Meta: Sendable, Decodable {
        let version: Int64

        enum CodingKeys: String, CodingKey {
            case version = "response_created_at"
        }
    }

    func replaceBotsiPaywall(version: Int64) -> Self {
        var mutable = self
        mutable.value.version = version
        return mutable
    }
}
