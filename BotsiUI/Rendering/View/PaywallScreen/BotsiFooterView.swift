////
////  BotsiFooterView.swift
////  Botsi
////
////  Created by Kostiantyn Antoniuk on 20.06.2025.
////
//
//import SwiftUI
//
//@available(iOS 15.0, *)
//public struct BotsiFooterView: View {
//    let model: BotsiFooterModel
//    let block: BotsiBlockMeta
//    
//    var body: some View {
//        VStack(spacing: model.content.spacing.toCGFloat()) {
//            ForEach(model.children, id: \.meta.id) { child in
//                BotsiBlockRendererView(from: child)
//            }
//        }
//        .padding(.all, model.content.padding.toCGFloat())
//        .background(
//            Color.fromRGBA(model.content.style.fill_color)
//        )
//        .cornerRadius(model.content.style.radius.toCGFloat())
//        .padding(.horizontal)
//    }
//}
