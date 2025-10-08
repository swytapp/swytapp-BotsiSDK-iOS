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

    // MARK: - Products
    static func makeProduct(product: BotsiProductItemModel,
                            productStyle: BotsiProductsModel) -> BotsiProductView {
        let viewModel = BotsiProductViewModel(product: product, productStyle: productStyle)
        return BotsiProductView(viewModel: viewModel)
    }

     static func makeNoToggleProducts(model: BotsiProductsModel,
                                   block: BotsiPaywallBlock) -> AnyView {
        let products = extractProducts(from: block.children ?? [])
        return AnyView(NoToggleProductsContainerView(model: model, products: products))
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

    static func makeTabProducts(model: BotsiProductsModel,
                                block: BotsiPaywallBlock) -> AnyView {
        guard let tabControlModel: BotsiTabControlModel = findModel(.tabControl, in: block) else {
            return AnyView(makeNoToggleProducts(model: model, block: block))
        }
        
        let tabGroups = block.children?.filter { $0.meta.type == .tab } ?? []
        let tabProducts: [(String, BotsiTabModel, [BotsiProductItemModel])] = tabGroups.compactMap { tabGroup in
            guard case .tab(let tabModel) = tabGroup.content else { return nil }
            let products = extractProducts(from: tabGroup.children ?? [])
            return (tabGroup.meta.id, tabModel, products)
        }
        return AnyView(TabProductsContainerView(model: model, tabControlModel: tabControlModel, tabModels: tabProducts))
    }
}

// MARK: - Private Helpers
@available(iOS 15.0, *)
private extension BotsiViewFactory {
    
    static func findModel<T>(_ type: BotsiBlockType, in block: BotsiPaywallBlock) -> T? {
        guard let content = block.children?.first(where: { $0.meta.type == type })?.content else { return nil }
        
        let mirror = Mirror(reflecting: content)
        return mirror.children.first?.value as? T
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
