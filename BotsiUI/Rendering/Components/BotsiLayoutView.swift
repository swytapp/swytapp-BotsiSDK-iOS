//
//  BotsiLayoutView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

//@available(iOS 15.0, *)
//struct BotsiLayoutView: View {
//    @ObservedObject var vm: BotsiLayoutViewModel
//
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            vm.model.background.ignoresSafeArea()
//
//            VStack(spacing: vm.model.spacing) {
//                topButtons
//                // child blocks
//                ForEach(vm.model.children) { BotsiBlockRenderer.render($0, delegate: vm.delegate) }
//            }
//            .padding(vm.model.margin)
//        }
//        .preferredColorScheme(vm.model.darkMode ? .dark : .light)
//        .onAppear { vm.delegate?.botsiPaywallDidOpen(vm.model.id) }
//    }
//
//    @ViewBuilder
//    private var topButtons: some View {
//        HStack {
//            ForEach(vm.model.topButtons) { btn in
//                switch btn.kind {
//                case .text(let title):
//                    Button(title) { vm.closeTapped() }
//                        .tint(btn.tint)
//                case .icon(let sys):
//                    Button(action: vm.closeTapped) {
//                        Image(systemName: sys)
//                    }.tint(btn.tint)
//                }
//            }
//        }
//    }
//}
