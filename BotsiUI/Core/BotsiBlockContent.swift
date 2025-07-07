//
//  BotsiBlockContent.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 19.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public enum BotsiBlockContent: Decodable, Sendable {
    case layout(BotsiLayoutModel)
    case heroImage(BotsiHeroImageModel)
    case timer(BotsiTimerModel)
    case carousel(BotsiCarouselModel)
    case links(BotsiLinksModel)
    case list(BotsiListModel)
    case listItem(BotsiListItemModel)
    case text(BotsiTextModel)
    case image(BotsiImageModel)
    case card(BotsiCardModel)
    case products(BotsiProductsModel)
    case productItem(BotsiProductItemModel)
    case footer(BotsiFooterModel)
    case button(BotsiButtonModel)
    case localization(BotsiLocalizationModel)
    case toggleControl(BotsiToggleControlModel)
    case unknown(EmptyContent?)

    public struct EmptyContent: Codable, Sendable {}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let meta = try container.decode(BotsiBlockMeta.self, forKey: .meta)

        switch meta.type {
        case .layout:
            let c = try container.decode(BotsiLayoutModel.self, forKey: .content)
            self = .layout(c)
        case .heroImage:
            let c = try container.decode(BotsiHeroImageModel.self, forKey: .content)
            self = .heroImage(c)
        case .timer:
            let c = try container.decode(BotsiTimerModel.self, forKey: .content)
            self = .timer(c)
        case .carousel:
            let c = try container.decode(BotsiCarouselModel.self, forKey: .content)
            self = .carousel(c)
        case .links:
            let c = try container.decode(BotsiLinksModel.self, forKey: .content)
            self = .links(c)
        case .list:
            let c = try container.decode(BotsiListModel.self, forKey: .content)
            self = .list(c)
        case .listItem:
            let c = try container.decode(BotsiListItemModel.self, forKey: .content)
            self = .listItem(c)
        case .text:
            let c = try container.decode(BotsiTextModel.self, forKey: .content)
            self = .text(c)
        case .image:
            let c = try container.decode(BotsiImageModel.self, forKey: .content)
            self = .image(c)
        case .card:
            let c = try container.decode(BotsiCardModel.self, forKey: .content)
            self = .card(c)
        case .products:
            let c = try container.decode(BotsiProductsModel.self, forKey: .content)
            self = .products(c)
        case .productItem:
            let c = try container.decode(BotsiProductItemModel.self, forKey: .content)
            self = .productItem(c)
        case .footer:
            let c = try container.decode(BotsiFooterModel.self, forKey: .content)
            self = .footer(c)
        case .button:
            let c = try container.decode(BotsiButtonModel.self, forKey: .content)
            self = .button(c)
        case .localization:
            let c = try container.decode(BotsiLocalizationModel.self, forKey: .content)
            self = .localization(c)
        default:
            self = .unknown(nil)
        }
    }

    private enum CodingKeys: String, CodingKey { case meta, content }
}


