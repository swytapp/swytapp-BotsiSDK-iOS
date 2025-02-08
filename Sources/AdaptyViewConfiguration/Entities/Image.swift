//
//  Image.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension BotsiViewConfiguration {
    package struct Image: Sendable, Hashable {
        static let defaultAspectRatio = AspectRatio.fit

        package let asset: Mode<ImageData>
        package let aspect: AspectRatio
        package let tint: Mode<Filling>?
    }
}

#if DEBUG
    package extension BotsiViewConfiguration.Image {
        static func create(
            asset: BotsiViewConfiguration.Mode<BotsiViewConfiguration.ImageData>,
            aspect: BotsiViewConfiguration.AspectRatio = defaultAspectRatio,
            tint: BotsiViewConfiguration.Mode<BotsiViewConfiguration.Filling>? = nil
        ) -> Self {
            .init(
                asset: asset,
                aspect: aspect,
                tint: tint
            )
        }
    }
#endif
