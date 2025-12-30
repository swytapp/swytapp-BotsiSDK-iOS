//
//  BotsiPaywallModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 19.06.2025.
//

@available(iOS 15.0, *)
public struct BotsiPaywallModel: Sendable {
    public let layout: BotsiPaywallBlock
    public let content: [BotsiPaywallBlock]
    public let footer: BotsiPaywallBlock?
    public let hero: BotsiPaywallBlock?
}

@available(iOS 15.0, *)
extension BotsiPaywallModel {
    var allBlocks: [BotsiPaywallBlock] {
        [layout, footer, hero].compactMap { $0 } + content
    }
}
