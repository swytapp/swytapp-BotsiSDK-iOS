//
//  BotsiUI+Facade.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI
import Botsi

@available(iOS 15.0, *)
enum BotsiUI {

    @MainActor
    static func makePaywall(paywall: BotsiPaywall?,
                                   builder data: Botsi.BotsiBuilder?,
                                   purchaseDelegate: BotsiPurchaseDelegate? = nil,
                                   onAction: ((BotsiAction) -> Void)? = nil,
                                   timerProvider: BotsiTimerProvider? = nil) throws -> some View {

        guard let data = data, let paywall = paywall else {
            throw BotsiUIError.paywallNotFound
        }

        let structure = try BotsiPaywallParser.parseStructure(from: data)
        
        guard let content = structure.content, let layout = structure.layout else {
            throw BotsiUIError.contentParsingError
        }

        let model = BotsiPaywallModel(layout: layout,
                                      content: content,
                                      footer: structure.footer,
                                      hero: structure.heroImage)

        let rootVM = BotsiPaywallViewModel(
            model: model,
            purchaseDelegate: purchaseDelegate,
            onAction: onAction,
            timerProvider: timerProvider
        )

        return BotsiPaywallScreen(viewModel: rootVM, paywall: paywall, purchaseDelegate: purchaseDelegate)
    }
}
