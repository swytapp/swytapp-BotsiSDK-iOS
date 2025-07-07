////
////  BotsiFooterBlockView.swift
////  Botsi
////
////  Created by Kostiantyn Antoniuk on 18.06.2025.
////
//
//import SwiftUI
//
//@available(iOS 15.0, *)
//struct FooterBlockView: BlockView {
//    
//    let viewModel: BotsiFooterViewModel
//
//    struct BotsiFooterViewModel: BlockViewModel {
//        let id: String
//        let padding: EdgeInsets
//        let children: [BlockModel]
//        
//        init(model: BotsiFooterModel, bus: BotsiPaywallEventBus) {
//            id = model.id
//            padding = model.padding
//            children = model.children
//        }
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            ForEach(viewModel.children) {
//                BotsiBlockRenderer.render($0, bus: PaywallEventBus.shared)
//            }
//        }
//        .padding(viewModel.padding)
//    }
//}
