//
//  NoToggleProductsContainerView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 02.10.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct NoToggleProductsContainerView: View {
    let model: BotsiProductsModel
    let products: [BotsiProductItemModel]
    let contentLayout: BotsiContentLayout
    let padding: BotsiEdge
    let offset: CGFloat
    
    init(model: BotsiProductsModel, products: [BotsiProductItemModel]) {
        self.model = model
        self.products = products
        self.contentLayout = model.contentLayout
        self.padding = model.padding
        self.offset = model.verticalOffset.toCGFloat()
    }
    
    init(model: BotsiProductsModel, products: [BotsiProductItemModel], layout: BotsiContentLayout, padding: BotsiEdge, offset: CGFloat) {
        self.model = model
        self.products = products
        self.contentLayout = layout
        self.padding = padding
        self.offset = offset
    }
    
    var body: some View {
        layoutContent
            .padding(padding)
            .offset(y: offset)
    }
    
    @ViewBuilder
    private var layoutContent: some View {
        switch contentLayout.layout {
        case .vertical:
            VStack(spacing: contentLayout.spacing) {
                productViews
            }
            .fixedSize(horizontal: false, vertical: true)
        case .horizontal:
            HStack(spacing: contentLayout.spacing) {
                productViews
            }
            .fixedSize(horizontal: false, vertical: true)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var productViews: some View {
        ForEach(products, id: \.id) { product in
            let viewModel = BotsiProductViewModel(product: product, productStyle: model, layout: contentLayout)
            BotsiProductView(viewModel: viewModel)
                .frame(maxHeight: .infinity)
        }
    }
}
