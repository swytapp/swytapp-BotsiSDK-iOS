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
    public let footerVM: BotsiFooterHelper?
    public let heroImage: BotsiHeroImageModel?
    
    public var heroHorizontalPadding: CGFloat {
        let left = (heroImage?.layout.padding.left ?? 0) + (layoutVM?.padding.left ?? 0)
        let right = (heroImage?.layout.padding.right ?? 0) + (layoutVM?.padding.right ?? 0)
        
        return left + right
    }

    init(model: BotsiPaywallModel, delegate: BotsiPaywallDelegate?) {
        self.delegate = delegate
        self.layoutVM = BotsiLayoutViewModel(model.layout)
        self.contentBlocks = model.content
        if let heroBlock = model.hero {
            if case let .heroImage(model) = heroBlock.content {
                self.heroImage = model
            } else {
                self.heroImage = nil
            }
        } else {
            self.heroImage = nil
        }
        
        
        if let footeBlock = model.footer {
            if case let .footer(model) = footeBlock.content {
                self.footerVM = BotsiFooterHelper(block: footeBlock, model: model)
            } else {
                self.footerVM = nil
            }
        } else {
            self.footerVM = nil
        }
    }

    func didClose() {
        delegate?.botsiPaywallDidClose()
    }
    
    func didTapPurchase(_ product: String?) {
        delegate?.botsiPaywallDidTapPurchase(product)
    }
}
