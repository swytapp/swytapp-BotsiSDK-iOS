//
//  VC.Asset.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension BotsiViewSource {
    enum Asset: Sendable {
        case filling(BotsiViewConfiguration.Filling)
        case image(BotsiViewConfiguration.ImageData)
        case video(BotsiViewConfiguration.VideoData)
        case font(BotsiViewConfiguration.Font)
        case unknown(String?)
    }
}

private extension BotsiViewSource.Asset {
    var asFilling: BotsiViewConfiguration.Filling {
        get throws {
            guard case let .filling(value) = self else {
                throw BotsiLocalizerError.wrongTypeAsset("color or any-gradient")
            }
            return value
        }
    }

    var asColor: BotsiViewConfiguration.Color {
        get throws {
            guard case let .filling(.solidColor(value)) = self else {
                throw BotsiLocalizerError.wrongTypeAsset("color")
            }
            return value
        }
    }

    var asImageData: BotsiViewConfiguration.ImageData {
        get throws {
            guard case let .image(value) = self else {
                throw BotsiLocalizerError.wrongTypeAsset("image")
            }
            return value
        }
    }

    var asVideoData: BotsiViewConfiguration.VideoData {
        get throws {
            guard case let .video(value) = self else {
                throw BotsiLocalizerError.wrongTypeAsset("video")
            }
            return value
        }
    }

    var asFont: BotsiViewConfiguration.Font {
        get throws {
            guard case let .font(value) = self else {
                throw BotsiLocalizerError.wrongTypeAsset("font")
            }
            return value
        }
    }
}

extension BotsiViewSource.Localizer {
    private enum AssetIdentifySufix: String {
        case darkMode = "@dark"
    }

    private func asset(_ assetId: String, darkMode mode: Bool = false) throws -> BotsiViewSource.Asset {
        guard let value = try assetOrNil(assetId, darkMode: mode) else {
            throw BotsiLocalizerError.notFoundAsset(assetId)
        }
        return value
    }

    private func assetOrNil(_ assetId: String, darkMode mode: Bool) throws -> BotsiViewSource.Asset? {
        let assetId = mode ? assetId + AssetIdentifySufix.darkMode.rawValue : assetId
        return localization?.assets?[assetId] ?? source.assets[assetId]
    }

    @inlinable
    func background(_ assetId: String) throws -> BotsiViewConfiguration.Background {
        switch try asset(assetId) {
        case let .filling(value):
            try .filling(.init(
                light: value,
                dark: assetOrNil(assetId, darkMode: true)?.asFilling
            ))
        case let .image(value):
            try .image(.init(
                light: value,
                dark: assetOrNil(assetId, darkMode: true)?.asImageData
            ))
        default:
            throw BotsiLocalizerError.wrongTypeAsset("color, any-gradient, or image")
        }
    }

    @inlinable
    func filling(_ assetId: String) throws -> BotsiViewConfiguration.Mode<BotsiViewConfiguration.Filling> {
        try BotsiViewConfiguration.Mode(
            light: asset(assetId).asFilling,
            dark: assetOrNil(assetId, darkMode: true)?.asFilling
        )
    }

    @inlinable
    func color(_ assetId: String) throws -> BotsiViewConfiguration.Mode<BotsiViewConfiguration.Color> {
        try BotsiViewConfiguration.Mode(
            light: asset(assetId).asColor,
            dark: try? assetOrNil(assetId, darkMode: true)?.asColor
        )
    }

    @inlinable
    func imageData(_ assetId: String) throws -> BotsiViewConfiguration.Mode<BotsiViewConfiguration.ImageData> {
        try BotsiViewConfiguration.Mode(
            light: asset(assetId).asImageData,
            dark: assetOrNil(assetId, darkMode: true)?.asImageData
        )
    }

    @inlinable
    func videoData(_ assetId: String) throws -> BotsiViewConfiguration.Mode<BotsiViewConfiguration.VideoData> {
        try BotsiViewConfiguration.Mode(
            light: asset(assetId).asVideoData,
            dark: assetOrNil(assetId, darkMode: true)?.asVideoData
        )
    }

    @inlinable
    func font(_ assetId: String) throws -> BotsiViewConfiguration.Font {
        try asset(assetId).asFont
    }
}

extension BotsiViewSource.Asset: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .filling(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .image(value):
            hasher.combine(value)
        case let .video(value):
            hasher.combine(value)
        case let .font(value):
            hasher.combine(2)
            hasher.combine(value)
        case let .unknown(value):
            hasher.combine(3)
            hasher.combine(value)
        }
    }
}

extension BotsiViewSource.Asset: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let type = try container.decodeIfPresent(String.self, forKey: .type) else {
            self = .unknown(nil)
            return
        }

        switch type {
        case let type where BotsiViewConfiguration.Filling.assetType(type):
            self = try .filling(BotsiViewConfiguration.Filling(from: decoder))
        case BotsiViewConfiguration.Font.assetType:
            self = try .font(BotsiViewConfiguration.Font(from: decoder))
        case BotsiViewConfiguration.ImageData.assetType:
            self = try .image(BotsiViewConfiguration.ImageData(from: decoder))
        case BotsiViewConfiguration.VideoData.assetType:
            self = try .video(BotsiViewConfiguration.VideoData(from: decoder))
        default:
            self = .unknown("asset.type: \(type)")
        }
    }
}

extension BotsiViewSource {
    struct AssetsContainer: Decodable {
        let value: [String: Asset]

        init(from decoder: Decoder) throws {
            struct Item: Decodable {
                let id: String
                let value: Asset

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: Asset.CodingKeys.self)
                    id = try container.decode(String.self, forKey: .id)
                    value = try decoder.singleValueContainer().decode(Asset.self)
                }
            }

            let array = try decoder.singleValueContainer().decode([Item].self)
            value = try [String: Asset](array.map { ($0.id, $0.value) }, uniquingKeysWith: { _, _ in
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Duplicate key"))
            })
        }
    }
}
