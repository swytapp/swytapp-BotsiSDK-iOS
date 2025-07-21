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
            BotsiLinksBlockView(model: model) { action in
                print("KA: Links action: \(action)")
            }
            
        case .layout(let model):
            EmptyView()
            
        case .timer(let model):
            BotsiTimerBlockView(model: model)
            
        case .carousel:
            BotsiCarouselBlockView(block: block)
            
        case .productItem(let model):
            EmptyView()
            
        case .heroImage(let model):
            EmptyView()
            
        case .list(let model):
            BotsiListBlockView(block: block)
            
        case .listItem(_):
            EmptyView()
            
        case .card(let model):
            let vm = BotsiCardViewModel(block: block, model: model)
            BotsiCardBlockView(viewModel: vm)
            
        case .toggleControl(let model):
            EmptyView()
            
        case .products(let model):
            if let toggleControlBlock = block.children?.first(where: { $0.meta.type.rawValue == "toggle_control" }),
               case .toggleControl(let toggleControlModel) = toggleControlBlock.content,
               let toggleOnBlock = block.children?.first(where: { $0.meta.type.rawValue == "toggle_on" }),
               case .toggleOn(let toggleOnModel) = toggleOnBlock.content,
               let toggleOffBlock = block.children?.first(where: { $0.meta.type.rawValue == "toggle_off" }),
               case .toggleOff(let toggleOffModel) = toggleOffBlock.content {
                
                let toggleChildren = toggleOffBlock.children?.filter { child in
                    child.meta.type.rawValue == "product_item"
                }
                
                let vm = BotsiProductsToggleViewModel(
                    contentModel: model,
                    toggleControlModel: toggleControlModel,
                    toggleOnModel: toggleOnModel,
                    toggleOffModel: toggleOffModel,
                    toggleChildren: toggleChildren ?? []
                )
                
                BotsiProductsToggleView(viewModel: vm)
            } else {
                EmptyView()
            }
            
        case .footer(let model):
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
