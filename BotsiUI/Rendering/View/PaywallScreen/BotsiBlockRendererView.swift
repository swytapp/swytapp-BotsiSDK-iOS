//
//  BotsiBlockRendererView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 04.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiBlockRendererView: View {
    
    let block: BotsiPaywallBlock
    let blockHeight: CGFloat?
    @EnvironmentObject var actionHandler: PaywallActionHandler
    
    public init(block: BotsiPaywallBlock, blockHeight: CGFloat? = nil) {
        self.block = block
        self.blockHeight = blockHeight
    }
    
    public var body: some View {
        switch block.content {
        case .text(let model):
            BotsiTextBlockView(model: model)
            
        case .image(let model):
            BotsiImageBlockView(model: model)
            
        case .button(let model):
            BotsiButtonBlockView(model: model)
            
        case .links(let model):
            BotsiLinksBlockView(model: model)
            
        case .timer(let model):
            BotsiViewFactory.makeTimer(model: model, timerProvider: actionHandler.timerProvider)
            
        case .carousel(let model):
            BotsiCarouselBlockView(block: block, model: model)
            
        case .list(let model):
            BotsiListBlockView(block: block)
            
        case .card(let model):
            BotsiCardBlockView(helper: BotsiCardHelper(block: block, model: model, blockHeight: blockHeight))
            
        case .products(let model):
            BotsiProductsContainerView(model: model, block: block)
            
        default:
            EmptyView()
        }
    }
}
