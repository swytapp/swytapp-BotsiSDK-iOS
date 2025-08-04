//
//  BotsiNoSwitchProductsView.swift
//  Botsi
//
//  Created by Konstantin on 31.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiNoSwitchProductsView: View {
    
    @ObservedObject var viewModel: BotsiNoSwitchProductsViewModel
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        Group {
            switch viewModel.productsLayout {
            case .horizontal:
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                        let vm = BotsiNoSwitchCardViewModel(model: item)
                        BotsiNoSwitchCardView(viewModel: vm, isSelected: selectedIndex == index)
                            .onTapGesture {
                                selectedIndex = index
                            }
                    }
                }
            case .vertical:
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                        let vm = BotsiNoSwitchCardViewModel(model: item)
                        BotsiNoSwitchCardView(viewModel: vm, isSelected: selectedIndex == index)
                            .onTapGesture {
                                selectedIndex = index
                            }
                    }
                }
            }
        }
    }
}
