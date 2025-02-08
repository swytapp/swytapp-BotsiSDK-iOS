//
//  VideoPlayer.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension BotsiViewConfiguration {
    package struct VideoPlayer: Hashable, Sendable {
        static let defaultAspectRatio = AspectRatio.fit

        package let asset: Mode<VideoData>

        package let aspect: AspectRatio
        package let loop: Bool
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.VideoPlayer {
        static func create(
            asset: BotsiViewConfiguration.Mode<BotsiViewConfiguration.VideoData>,
            aspect: BotsiViewConfiguration.AspectRatio = defaultAspectRatio,
            loop: Bool = true
        ) -> Self {
            .init(
                asset: asset,
                aspect: aspect,
                loop: loop
            )
        }
    }
#endif
