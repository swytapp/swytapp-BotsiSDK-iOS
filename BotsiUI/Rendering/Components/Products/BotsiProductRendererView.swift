//
//  BotsiProductRendererView.swift
//  Botsi
//
//  Created by Konstantin on 29.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiProductRendererView: View {

    private let block: BotsiPaywallBlock
    private let onAction: (BotsiActionType) -> Void

    private let model: BotsiProductsModel

    public init?(block: BotsiPaywallBlock, onAction: @escaping (BotsiActionType) -> Void) {
        guard case let .products(model) = block.content else {
            return nil
        }
        self.block = block
        self.model = model
        self.onAction = onAction
    }

    // MARK: - Body
    public var body: some View {
        switch model.grouping {
        case .noSwitch:
            NoSwitchView()
        case .toggle:
            ToggleView()
        case .tabs:
            TabsView()
        case .revealMore:
            RevealMoreView()
        case .bottomSheet:
            BottomSheetView()
        case .unknown:
            EmptyView()
        }
    }
}

// MARK: - Private methods
@available(iOS 15.0, *)
private extension BotsiProductRendererView {
    
    @ViewBuilder
    func ToggleView() -> some View {
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
    }
    
    @ViewBuilder
    func NoSwitchView() -> some View {
        let vm = BotsiNoSwitchProductsViewModel(block: block, model: model)
        BotsiNoSwitchProductsView(viewModel: vm)
    }
    
    @ViewBuilder
    func TabsView() -> some View {
        EmptyView()
    }
    
    @ViewBuilder
    func RevealMoreView() -> some View {
        EmptyView()
    }
    
    @ViewBuilder
    func BottomSheetView() -> some View {
        EmptyView()
    }
}
