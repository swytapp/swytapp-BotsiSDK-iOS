//
//  BotsiNoSwitchViewModel.swift
//  Botsi
//
//  Created by Konstantin on 01.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
public final class BotsiNoSwitchProductsViewModel: ObservableObject {

    @Published var items: [BotsiProductItemModel] = []
    @Published var selectedIndex: Int = 0
    
    private let model: BotsiProductsModel
    
    var productsLayout: BotsiLayout {
        model.contentLayout.layout
    }

    public init(block: BotsiPaywallBlock, model: BotsiProductsModel) {
        let childrenItems: [BotsiProductItemModel] = block.children?.compactMap {
            if $0.meta.type == .productItem,
               case let .productItem(model) = $0.content {
                return model
            }
            return nil
        } ?? []

        self.items = childrenItems
        self.model = model
    }

    func select(at index: Int) {
        guard index < items.count else { return }
        selectedIndex = index
        for item in items.indices {
            print("KA: item \(item)")
        }
    }

//    var selectedItem: ProductItem? {
//        items.first(where: { $0.isSelected })
//    }
}
