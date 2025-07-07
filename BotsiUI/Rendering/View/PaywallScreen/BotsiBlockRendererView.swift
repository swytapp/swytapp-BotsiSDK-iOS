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
            BotsiLinksBlockView(viewModel: vm)
            
        case .layout(let model):
            //            BotsiLayoutView(model: model)
            EmptyView()
            
        case .footer(let model):
            let vm = BotsiFooterViewModel(model)
            BotsiFooterView(vm: vm)
            
        case .timer(let model):
            let vm = BotsiTimerViewModel(model)
            BotsiTimerBlockView(viewModel: vm)
            
        case .carousel:
            BotsiCarouselBlockView(block: block)
            
        case .productItem(let model):
            //            BotsiProductItemView(model: model)
            EmptyView()
            
        case .heroImage(let model):
            //            BotsiHeroImageView(model: model)
            EmptyView()
        case .list(let model):
            BotsiListBlockView(block: block)
        case .listItem(_):
            EmptyView()
        case .card(let model):
            let vm = BotsiCardViewModel(block: block, model: model)
            BotsiCardBlockView(viewModel: vm)
        case .toggleControl(_):
            EmptyView()
        case .products(_):
            EmptyView()
        case .localization(_):
            EmptyView()
        case .unknown(_):
            EmptyView()
        default:
            EmptyView()
        }
    }
}
