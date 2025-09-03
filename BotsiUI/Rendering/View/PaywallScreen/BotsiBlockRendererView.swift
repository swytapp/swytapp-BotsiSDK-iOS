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
    let onAction: (BotsiActionType) -> Void
    
    public var body: some View {
        switch block.content {
        case .text(let model):
            BotsiTextBlockView(model: model)
            
        case .image(let model):
            BotsiImageBlockView(model: model)
            
        case .button(let model):
            let vm = BotsiButtonViewModel(model: model)
            BotsiButtonBlockView(viewModel: vm)
            
        case .links(let model):
            let vm = BotsiLinksViewModel(model)
            BotsiLinksBlockView(model: model)
            
        case .timer(let model):
            BotsiTimerBlockView(model: model)
            
        case .carousel:
            BotsiCarouselBlockView(block: block)
            
        case .list(let model):
            BotsiListBlockView(block: block)
            
        case .card(let model):
            let helper = BotsiCardHelper(block: block, model: model)
            BotsiCardBlockView(helper: helper)
            
        case .products(let model):
            BotsiProductRendererView(block: block, onAction: onAction)
            
        case .layout, .productItem, .heroImage, .listItem, .toggleControl, .footer, .localization, .unknown:
            EmptyView()
            
        default:
            EmptyView()
        }
    }
}
