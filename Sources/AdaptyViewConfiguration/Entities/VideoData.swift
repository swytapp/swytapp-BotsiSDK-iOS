//
//  VideoData.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension BotsiViewConfiguration {
    package enum VideoData: Sendable {
        case url(URL, image: ImageData)
        case resources(String, image: ImageData)

        var image: ImageData {
            switch self {
            case let .url(_, image),
                 let .resources(_, image):
                image
            }
        }
    }
}

extension BotsiViewConfiguration.VideoData: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .url(url, img):
            hasher.combine(url)
            hasher.combine(img)
        case let .resources(value, img):
            hasher.combine(value)
            hasher.combine(img)
        }
    }
}

extension BotsiViewConfiguration.VideoData: Decodable {
    static let assetType = "video"

    private enum CodingKeys: String, CodingKey {
        case url
        case image
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self = try .url(
            container.decode(URL.self, forKey: .url),
            image: container.decode(BotsiViewConfiguration.ImageData.self, forKey: .image)
        )
    }
}
