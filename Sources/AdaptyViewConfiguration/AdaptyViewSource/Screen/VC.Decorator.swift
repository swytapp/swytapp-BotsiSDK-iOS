//
//  VC.Decorator.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension BotsiViewSource {
    struct Decorator: Sendable, Hashable {
        let shapeType: BotsiViewConfiguration.ShapeType
        let backgroundAssetId: String?
        let borderAssetId: String?
        let borderThickness: Double?
    }
}

extension BotsiViewSource.Localizer {
    func decorator(_ from: BotsiViewSource.Decorator) throws -> BotsiViewConfiguration.Decorator {
        .init(
            shapeType: from.shapeType,
            background: from.backgroundAssetId.flatMap { try? background($0) },
            border: from.borderAssetId.map { (try? filling($0)) ?? BotsiViewConfiguration.Border.default.filling }.map {
                BotsiViewConfiguration.Border(filling: $0, thickness: from.borderThickness ?? BotsiViewConfiguration.Border.default.thickness)
            }
        )
    }
}

extension BotsiViewSource.Decorator: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case rectangleCornerRadius = "rect_corner_radius"
        case borderAssetId = "border"
        case borderThickness = "thickness"
        case shapeType = "type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backgroundAssetId = try container.decodeIfPresent(String.self, forKey: .backgroundAssetId)
        let shape = (try? container.decode(BotsiViewConfiguration.ShapeType.self, forKey: .shapeType)) ?? BotsiViewConfiguration.Decorator.defaultShapeType

        if case .rectangle = shape,
           let rectangleCornerRadius = try container.decodeIfPresent(BotsiViewConfiguration.CornerRadius.self, forKey: .rectangleCornerRadius) {
            shapeType = .rectangle(cornerRadius: rectangleCornerRadius)
        } else {
            shapeType = shape
        }

        if let assetId = try container.decodeIfPresent(String.self, forKey: .borderAssetId) {
            borderAssetId = assetId
            borderThickness = try container.decodeIfPresent(Double.self, forKey: .borderThickness)
        } else {
            borderAssetId = nil
            borderThickness = nil
        }
    }
}
