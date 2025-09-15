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
    @EnvironmentObject var actionHandler: PaywallActionHandler
    
    public var body: some View {
        switch block.content {
        case .text(let model):
            BotsiTextBlockView(model: model)
            
        case .image(let model):
            BotsiImageBlockView(model: model)
            
        case .button(let model):
            BotsiViewFactory.makeButton(model: model)
            
        case .links(let model):
            BotsiLinksBlockView(model: model)
            
        case .timer(let model):
            BotsiViewFactory.makeTimer(model: model, timerProvider: actionHandler.timerProvider)
            
        case .carousel(let model):
            BotsiCarouselBlockView(block: block, model: model)
            
        case .list(let model):
            BotsiListBlockView(block: block)
            
        case .card(let model):
            BotsiCardBlockView(helper: BotsiCardHelper(block: block, model: model))
            
        case .products(let model):
            BotsiProductRendererView(block: block) { _  in }
            
        case .layout, .productItem, .heroImage, .listItem, .toggleControl, .footer, .localization, .unknown:
            EmptyView()
            
        default:
            EmptyView()
        }
    }
}
