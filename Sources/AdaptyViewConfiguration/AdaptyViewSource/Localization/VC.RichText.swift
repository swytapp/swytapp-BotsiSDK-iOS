//
//  VC.RichText.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 15.03.2024
//
//

import Foundation

extension BotsiViewSource {
    struct TextAttributes: Sendable, Hashable {
        let fontAssetId: String?
        let size: Double?
        let txtColorAssetId: String?
        let imgTintColorAssetId: String?
        let backgroundAssetId: String?
        let strike: Bool?
        let underline: Bool?

        var isEmpty: Bool {
            fontAssetId == nil
                && size == nil
                && txtColorAssetId == nil
                && imgTintColorAssetId == nil
                && backgroundAssetId == nil
                && strike == nil
                && underline == nil
        }
    }

    struct RichText: Sendable, Hashable {
        let items: [RichText.Item]

        var isEmpty: Bool { items.isEmpty }

        enum Item: Sendable {
            case text(String, TextAttributes?)
            case tag(String, TextAttributes?)
            case image(String, TextAttributes?)
            case unknown
        }
    }
}

extension BotsiViewSource.Localizer {
    func urlIfPresent(_ stringId: String?) -> String? {
        guard let stringId, let item = self.localization?.strings?[stringId] else { return nil }
        return item.value.asString ?? item.fallback?.asString
    }

    func richText(
        stringId: String,
        defaultTextAttributes: BotsiViewSource.TextAttributes?
    ) -> BotsiViewConfiguration.RichText? {
        guard let item = localization?.strings?[stringId] else { return nil }
        return BotsiViewConfiguration.RichText(
            items: item.value.convert(
                self,
                defaultTextAttributes: defaultTextAttributes
            ),
            fallback: item.fallback.map { $0.convert(
                self,
                defaultTextAttributes: defaultTextAttributes
            ) }
        )
    }
}

private extension BotsiViewSource.RichText {
    var asString: String? {
        items.first.flatMap {
            if case let .text(value, attr) = $0, attr == nil { value } else { nil }
        }
    }

    func convert(
        _ localizer: BotsiViewSource.Localizer,
        defaultTextAttributes: BotsiViewSource.TextAttributes?
    ) -> [BotsiViewConfiguration.RichText.Item] {
        items.compactMap { item in
            switch item {
            case let .text(value, attr):
                .text(value, attr.add(defaultTextAttributes).convert(localizer))
            case let .tag(value, attr):
                .tag(value, attr.add(defaultTextAttributes).convert(localizer))
            case let .image(assetId, attr):
                    .image(try? localizer.imageData(assetId), attr.add(defaultTextAttributes).convert(localizer))
            default:
                nil
            }
        }
    }
}

private extension BotsiViewSource.TextAttributes {
    func add(
        _ other: BotsiViewSource.TextAttributes?
    ) -> BotsiViewSource.TextAttributes {
        guard let other else { return self }
        return BotsiViewSource.TextAttributes(
            fontAssetId: fontAssetId ?? other.fontAssetId,
            size: size ?? other.size,
            txtColorAssetId: txtColorAssetId ?? other.txtColorAssetId,
            imgTintColorAssetId: imgTintColorAssetId ?? other.imgTintColorAssetId,
            backgroundAssetId: backgroundAssetId ?? other.backgroundAssetId,
            strike: strike ?? other.strike,
            underline: underline ?? other.underline
        )
    }
}

private extension BotsiViewSource.TextAttributes? {
    func add(
        _ other: BotsiViewSource.TextAttributes?
    ) -> BotsiViewSource.TextAttributes? {
        switch self {
        case .none:
            other
        case let .some(value):
            value.add(other)
        }
    }

    func convert(
        _ localizer: BotsiViewSource.Localizer
    ) -> BotsiViewConfiguration.RichText.TextAttributes {
        let attr = self
        let font = (try? attr?.fontAssetId.map(localizer.font)) ?? BotsiViewConfiguration.Font.default
        return BotsiViewConfiguration.RichText.TextAttributes(
            font: font,
            size: attr?.size ?? font.defaultSize,
            txtColor: (try? attr?.txtColorAssetId.map(localizer.filling)) ?? .same(font.defaultColor),
            imgTintColor: try? attr?.imgTintColorAssetId.map(localizer.filling),
            background: try? attr?.backgroundAssetId.map(localizer.filling),
            strike: attr?.strike ?? false,
            underline: attr?.underline ?? false
        )
    }
}

extension BotsiViewSource.RichText.Item: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(value, attr):
            hasher.combine(1)
            hasher.combine(value)
            hasher.combine(attr)
        case let .tag(value, attr):
            hasher.combine(2)
            hasher.combine(value)
            hasher.combine(attr)
        case let .image(value, attr):
            hasher.combine(3)
            hasher.combine(value)
            hasher.combine(attr)
        case .unknown:
            hasher.combine(4)
        }
    }
}

extension BotsiViewSource.RichText: Decodable {
    init(from decoder: Decoder) throws {
        items =
            if let value = try? Item(from: decoder) {
                [value]
            } else {
                try [Item](from: decoder)
            }
    }
}

extension BotsiViewSource.RichText.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case text
        case tag
        case image
        case attributes
    }

    init(from decoder: Decoder) throws {
        if let value = try? (try? decoder.singleValueContainer())?.decode(String.self) {
            self = .text(value, nil)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self =
            if container.contains(.text) {
                try .text(
                    container.decode(String.self, forKey: .text),
                    container.decodeIfPresent(BotsiViewSource.TextAttributes.self, forKey: .attributes)
                )
            } else if container.contains(.tag) {
                try .tag(
                    container.decode(String.self, forKey: .tag),
                    container.decodeIfPresent(BotsiViewSource.TextAttributes.self, forKey: .attributes)
                )
            } else if container.contains(.image) {
                try .image(
                    container.decode(String.self, forKey: .image),
                    container.decodeIfPresent(BotsiViewSource.TextAttributes.self, forKey: .attributes)
                )
            } else {
                .unknown
            }
    }
}

extension BotsiViewSource.TextAttributes: Decodable {
    enum CodingKeys: String, CodingKey {
        case size
        case fontAssetId = "font"
        case txtColorAssetId = "color"
        case imgTintColorAssetId = "tint"
        case backgroundAssetId = "background"
        case strike
        case underline
    }
}
