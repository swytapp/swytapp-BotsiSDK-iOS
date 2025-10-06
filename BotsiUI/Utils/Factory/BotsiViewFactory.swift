//
//  BotsiViewFactory.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@MainActor
@available(iOS 15.0, *)
public enum BotsiViewFactory {
    
    static func makeTimer(
        model: BotsiTimerModel,
        timerProvider: BotsiTimerProvider? = nil
    ) -> BotsiTimerBlockView {
        let viewModel = BotsiTimerViewModel(model: model, timerProvider: timerProvider)
        return BotsiTimerBlockView(viewModel: viewModel)
    }
    
    static func makeButton(model: BotsiButtonModel) -> BotsiButtonBlockView {
        let viewModel = BotsiButtonViewModel(model: model)
        return BotsiButtonBlockView(viewModel: viewModel)
    }

    // MARK: - Products
    static func makeProduct(product: BotsiProductItemModel,
                            productStyle: BotsiProductsModel) -> BotsiProductView {
        let viewModel = BotsiProductViewModel(product: product, productStyle: productStyle)
        return BotsiProductView(viewModel: viewModel)
    }
    
    static func makeToggleProducts(model: BotsiProductsModel,
                                  block: BotsiPaywallBlock) -> AnyView {
        guard let toggleModel: BotsiToggleControlModel = findModel(.toggleControl, in: block),
              let toggleOnModel: BotsiToggleOnModel = findModel(.toggleOn, in: block),
              let toggleOffModel: BotsiToggleOffModel = findModel(.toggleOff, in: block) else {
            return AnyView(makeNoToggleProducts(model: model, block: block))
        }
        
        let toggleOnProducts = extractProducts(from: findBlock(.toggleOn, in: block)?.children ?? [])
        let toggleOffProducts = extractProducts(from: findBlock(.toggleOff, in: block)?.children ?? [])
        
        return AnyView(ToggleProductsContainerView(model: model,
                                                   toggleOnProducts: toggleOnProducts, 
                                                   toggleOffProducts: toggleOffProducts,
                                                   toggleOnModel: toggleOnModel, 
                                                   toggleOffModel: toggleOffModel,
                                                   toggleModel: toggleModel))
    }
    
    static func makeNoToggleProducts(model: BotsiProductsModel,
                                   block: BotsiPaywallBlock) -> AnyView {
        let products = extractProducts(from: block.children ?? [])
        return AnyView(NoToggleProductsContainerView(model: model, products: products))
    }
}

// MARK: - Private Helpers
@available(iOS 15.0, *)
private extension BotsiViewFactory {
    
    static func findModel<T>(_ type: BotsiBlockType, in block: BotsiPaywallBlock) -> T? {
        guard let content = block.children?.first(where: { $0.meta.type == type })?.content else { return nil }
        
        switch type {
        case .toggleControl:
            if case .toggleControl(let model) = content { return model as? T }
        case .toggleOn:
            if case .toggleOn(let model) = content { return model as? T }
        case .toggleOff:
            if case .toggleOff(let model) = content { return model as? T }
        default:
            break
        }
        return nil
    }
    
    static func findBlock(_ type: BotsiBlockType, in block: BotsiPaywallBlock) -> BotsiPaywallBlock? {
        block.children?.first { $0.meta.type == type }
    }
    
    static func extractProducts(from blocks: [BotsiPaywallBlock]) -> [BotsiProductItemModel] {
        blocks.compactMap { block in
            guard block.meta.type == .productItem,
                  case .productItem(var productModel) = block.content,
                  let productId = block.meta.productId else {
                return nil
            }
            productModel.productId = productId
            return productModel
        }
    }
}
