//
//  VC.Screen.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension BotsiViewSource {
    struct Screen: Sendable, Hashable  {
        let backgroundAssetId: String?
        let cover: Box?
        let content: Element
        let footer: Element?
        let overlay: Element?
        let selectedBotsiProductId: String?
    }
}

extension BotsiViewSource.Localizer {
    func screen(_ from: BotsiViewSource.Screen) throws -> BotsiViewConfiguration.Screen {
        try .init(
            background: from.backgroundAssetId.flatMap { try? background($0) } ?? BotsiViewConfiguration.Screen.defaultBackground,
            cover: from.cover.map(box),
            content: element(from.content),
            footer: from.footer.map(element),
            overlay: from.overlay.map(element),
            selectedBotsiProductId: from.selectedBotsiProductId
        )
    }

    func bottomSheet(_ from: BotsiViewSource.Screen) throws -> BotsiViewConfiguration.BottomSheet {
        try .init(
            content: element(from.content)
        )
    }
}

extension BotsiViewSource.Screen: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case cover
        case content
        case footer
        case overlay
        case selectedBotsiProductId = "selected_product"
    }
}
