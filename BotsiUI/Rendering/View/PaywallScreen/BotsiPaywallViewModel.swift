//
//  BotsiPaywallViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 20.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
public final class BotsiPaywallViewModel: ObservableObject {
    
    public weak var delegate: BotsiPaywallDelegate?

    public let contentBlocks: [BotsiPaywallBlock]
    public let layoutVM: BotsiLayoutViewModel?

    init(model: BotsiPaywallModel, delegate: BotsiPaywallDelegate?) {
        self.delegate = delegate
        self.layoutVM = BotsiLayoutViewModel(model.layout)
        self.contentBlocks = model.content
    }

    func didClose() {
        delegate?.botsiPaywallDidClose()
    }
    
    func didTapPurchase(_ product: String?) {
        delegate?.botsiPaywallDidTapPurchase(product)
    }
}
