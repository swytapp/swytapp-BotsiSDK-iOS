//
//  BotsiPaywallScreen.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 19.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiPaywallScreen: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: BotsiPaywallViewModel

    public init(viewModel: BotsiPaywallViewModel) {
        _vm = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        let margins = vm.layoutVM?.model.contentLayout.margin
        ZStack {
            ScrollView {
                VStack(spacing: vm.layoutVM?.spacing) {
                    ForEach(vm.contentBlocks, id: \.meta.id) { block in
                        BotsiBlockRendererView(block: block) { action in
                            print("KA: Paywall action  \(action)")
                        }
                    }
                }
                .padding(.leading, vm.layoutVM?.padding.left)
                .padding(.top, vm.layoutVM?.padding.top)
                .padding(.trailing, vm.layoutVM?.padding.right)
                .padding(.bottom, vm.layoutVM?.padding.bottom)
            }
            .backgroundFill(vm.layoutVM?.fillColor)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
            BotsiTopButtonsRenderer(layout: vm.layoutVM?.model)
            
//            if let footerBlock = vm.footerVM?.model {
//                VStack(spacing: 0) {
//                    Divider()
//                    BotsiBlockRenderer(block: footerBlock)
//                        .padding(.top, 8)
//                        .padding(.horizontal)
//                        .background(.ultraThinMaterial)
//                }
//                .transition(.move(edge: .bottom))
//            }
        }
        .frame(maxWidth: .infinity)
    }
}

@available(iOS 15.0, *)
extension BotsiPaywallScreen {
    @available(iOS 15.0, *)
    @ViewBuilder
    func BotsiTopButtonsRenderer(layout: BotsiLayoutModel?) -> some View {
        if let buttons = layout?.buttons, !buttons.isEmpty {
            TopButtonsOverlayView(buttons: buttons) { action in
                dismiss()
            }
        }
    }
}

#Preview {
    HStack {
        if #available(iOS 15.0, *) {
            Button {
                
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        .black.opacity(40),
                        lineWidth: 1
                    )
                    .background(.green)
                    .overlay(
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                    )
                    .cornerRadius(16)
            }
            .frame(width: 32, height: 32)
            .opacity(40)
        } else {
            // Fallback on earlier versions
        }
    }
}
