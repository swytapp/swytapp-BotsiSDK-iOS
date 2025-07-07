////
////  BotsiProductsBlockView.swift
////  Botsi
////
////  Created by Kostiantyn Antoniuk on 18.06.2025.
////
//
//import SwiftUI
//
//@available(iOS 15.0, *)
//struct BotsiProductsBlockView: BlockView {
//    
//    let viewModel: ProductsStaticViewModel
//    
//    struct ProductsStaticViewModel: BlockViewModel {
//        
//        let id: String
//        let items: [BlockModel]
//        let bus: BotsiPaywallEventBus
//        
//        init(model: BotsiProductsModel, bus: BotsiPaywallEventBus) {
//            id = model.id
//            items = model.children
//            self.bus = bus
//        }
//    }
//    var body: some View {
//        VStack(spacing: 8) {
//            ForEach(viewModel.items) {
//                BotsiBlockRenderer.render($0, bus: viewModel.bus)
//            }
//        }
//    }
//}
