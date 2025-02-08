//
//  VC.VideoPlayer.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension BotsiViewSource {
    struct VideoPlayer: Hashable, Sendable {
        let assetId: String
        let aspect: BotsiViewConfiguration.AspectRatio
        let loop: Bool
    }
}

extension BotsiViewSource.Localizer {
    func videoPlayer(_ from: BotsiViewSource.VideoPlayer) throws -> BotsiViewConfiguration.VideoPlayer {
        try .init(
            asset: videoData(from.assetId),
            aspect: from.aspect,
            loop: from.loop
        )
    }
}

extension BotsiViewSource.VideoPlayer: Decodable {
    enum CodingKeys: String, CodingKey {
        case assetId = "asset_id"
        case aspect
        case loop
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assetId = try container.decode(String.self, forKey: .assetId)
        aspect = try container.decodeIfPresent(BotsiViewConfiguration.AspectRatio.self, forKey: .aspect) ?? BotsiViewConfiguration.VideoPlayer.defaultAspectRatio
        loop = try container.decodeIfPresent(Bool.self, forKey: .loop) ?? true
    }
}
