//
//  BotsiProductsContainerView.swift
//  BotsiUI
//
//  Created by Vladyslav on 22.03.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiProductsContainerView: View {
    private let model: BotsiProductsModel
    private let block: BotsiPaywallBlock
    
    public init(model: BotsiProductsModel, block: BotsiPaywallBlock) {
        self.model = model
        self.block = block
    }
    
    public var body: some View {
        Group {
            switch model.grouping {
            case .noSwitch:
                BotsiViewFactory.makeNoToggleProducts(model: model, block: block)
            case .toggle:
                BotsiViewFactory.makeToggleProducts(model: model, block: block)
            case .tabs:
                BotsiViewFactory.makeTabProducts(model: model, block: block)
            case .revealMore:
                BotsiViewFactory.makeMorePlans(model: model, block: block)
            case .bottomSheet:
                BotsiViewFactory.makeMorePlans(model: model, block: block)
            case .unknown:
                BotsiViewFactory.makeNoToggleProducts(model: model, block: block)
            }
        }
    }
}

