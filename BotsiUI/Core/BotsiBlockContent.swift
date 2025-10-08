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
    case footer(BotsiFooterModel)
    case button(BotsiButtonModel)
    case localization(BotsiLocalizationModel)
    
    case products(BotsiProductsModel)
    case productItem(BotsiProductItemModel)
    case toggleControl(BotsiToggleControlModel)
    case toggleOn(BotsiToggleOnModel)
    case toggleOff(BotsiToggleOffModel)
    case tabControl(BotsiTabControlModel)
    case tab(BotsiTabModel)
    
    case unknown(EmptyContent?)

    public struct EmptyContent: Codable, Sendable {}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let meta = try container.decode(BotsiBlockMeta.self, forKey: .meta)

        switch meta.type {
        case .layout:
            self = .layout(try container.decode(BotsiLayoutModel.self, forKey: .content))
        case .heroImage:
            self = .heroImage(try container.decode(BotsiHeroImageModel.self, forKey: .content))
        case .timer:
            self = .timer(try container.decode(BotsiTimerModel.self, forKey: .content))
        case .carousel:
            self = .carousel(try container.decode(BotsiCarouselModel.self, forKey: .content))
        case .links:
            self = .links(try container.decode(BotsiLinksModel.self, forKey: .content))
        case .list:
            self = .list(try container.decode(BotsiListModel.self, forKey: .content))
        case .listItem:
            self = .listItem(try container.decode(BotsiListItemModel.self, forKey: .content))
        case .text:
            self = .text(try container.decode(BotsiTextModel.self, forKey: .content))
        case .image:
            self = .image(try container.decode(BotsiImageModel.self, forKey: .content))
        case .card:
            self = .card(try container.decode(BotsiCardModel.self, forKey: .content))
        case .footer:
            self = .footer(try container.decode(BotsiFooterModel.self, forKey: .content))
        case .button:
            self = .button(try container.decode(BotsiButtonModel.self, forKey: .content))
        case .localization:
            self = .localization(try container.decode(BotsiLocalizationModel.self, forKey: .content))
        case .products:
            self = .products(try container.decode(BotsiProductsModel.self, forKey: .content))
        case .productItem:
            self = .productItem(try container.decode(BotsiProductItemModel.self, forKey: .content))
        case .toggleControl:
            self = .toggleControl(try container.decode(BotsiToggleControlModel.self, forKey: .content))
        case .toggleOn:
            self = .toggleOn(try container.decode(BotsiToggleOnModel.self, forKey: .content))
        case .toggleOff:
            self = .toggleOff(try container.decode(BotsiToggleOffModel.self, forKey: .content))
        case .tabControl:
            self = .tabControl(try container.decode(BotsiTabControlModel.self, forKey: .content))
        case .tab:
            self = .tab(try container.decode(BotsiTabModel.self, forKey: .content))
        default:
            self = .unknown(nil)
        }
    }

    private enum CodingKeys: String, CodingKey { case meta, content }
    
    public var padding: BotsiEdge? {
        let mirror = Mirror(reflecting: self)
        guard let model = mirror.children.first?.value,
              let paddingProvider = model as? BotsiPaddingProvider else {
            return nil
        }
        return paddingProvider.padding
    }
}


