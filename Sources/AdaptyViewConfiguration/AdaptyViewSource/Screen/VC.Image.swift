//
//  VC.Image.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension BotsiViewSource {
    struct Image: Sendable, Hashable {
        let assetId: String
        let aspect: BotsiViewConfiguration.AspectRatio
        let tintAssetId: String?
    }
}

extension BotsiViewSource.Localizer {
    func image(_ from: BotsiViewSource.Image) throws -> BotsiViewConfiguration.Image {
        try .init(
            asset: imageData(from.assetId),
            aspect: from.aspect,
            tint: from.tintAssetId.flatMap { try? filling($0) }
        )
    }
}

extension BotsiViewSource.Image: Decodable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case tintAssetId = "tint"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assetId = try container.decode(String.self, forKey: .assetId)
        aspect = try container.decodeIfPresent(BotsiViewConfiguration.AspectRatio.self, forKey: .aspect) ?? BotsiViewConfiguration.Image.defaultAspectRatio
        tintAssetId = try container.decodeIfPresent(String.self, forKey: .tintAssetId)
    }
}
