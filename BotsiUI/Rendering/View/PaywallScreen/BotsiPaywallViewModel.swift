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
    public let timerProvider: BotsiTimerProvider?
    @Published public var shouldDismiss: Bool = false
    
    public let contentBlocks: [BotsiPaywallBlock]
    public let layoutVM: BotsiLayoutViewModel?
    public let footerVM: BotsiFooterHelper?
    public let heroImage: BotsiHeroImageModel?
    
    public var heroHorizontalPadding: CGFloat {
        let left = (heroImage?.layout.padding.left ?? 0) + (layoutVM?.padding.left ?? 0)
        let right = (heroImage?.layout.padding.right ?? 0) + (layoutVM?.padding.right ?? 0)
        
        return left + right
    }
    
    init(model: BotsiPaywallModel, delegate: BotsiPaywallDelegate?, timerProvider: BotsiTimerProvider? = nil) {
        self.delegate = delegate
        self.timerProvider = timerProvider
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
        shouldDismiss = true
    }
    
    func didTapPurchase(_ product: String?) {
        delegate?.botsiPaywallDidTapPurchase(product)
    }
    
    func didTapRestore() {
        delegate?.botsiPaywallDidTapRestore()
    }
    
    func didTapLogin() {
        delegate?.botsiPaywallDidTapLogin()
    }
    
    func didTapCustom(id: String) {
        delegate?.botsiPaywallDidTapCustom(id: id)
    }

    func openUrl(url: String) {
        if let urlObject = URL(string: url) {
            delegate?.botsiPaywallDidOpenURL(urlObject)
            
            Task { @MainActor in
                await UIApplication.shared.open(urlObject)
            }
        }
    }

    func didEndTimer(id: String?) {
        delegate?.botsiPaywallDidEndTimer(id: id)
    }
}
