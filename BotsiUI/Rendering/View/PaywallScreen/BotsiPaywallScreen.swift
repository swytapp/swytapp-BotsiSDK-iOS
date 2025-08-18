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
    @Environment(\.screenSize) private var screenSize
    @StateObject var vm: BotsiPaywallViewModel
    
    public init(viewModel: BotsiPaywallViewModel) {
        _vm = .init(wrappedValue: viewModel)
    }
    
    public var body: some View {
        let margins = vm.layoutVM?.model.contentLayout.margin
        GeometryReader { proxy in
            VStack {
                ZStack {
                    switch vm.heroImage?.style {
                    case .transparent:
                        BotsiHeroImageView(model: vm.heroImage!)
                        ContentScroll(height: proxy.size.height)
                        
                    case .overlay:
                        VStack(spacing: 0) {
                            BotsiHeroImageView(model: vm.heroImage!)
                                .frame(height: proxy.size.height * ((vm.heroImage?.heightPercent ?? 0.3) + 0.08))
                                .clipped()
                            Spacer()
                            
                        }
                        .frame(maxHeight: .infinity)
                        .backgroundFill(vm.layoutVM?.fillColor)
                        .ignoresSafeArea()
                        
                        ContentScroll(height: proxy.size.height)
                            .ignoresSafeArea()
                        
                    case .flat, .none:
                        ContentScroll(height: proxy.size.height)
                            .ignoresSafeArea()
                    }
                    
                    BotsiTopButtonsRenderer(layout: vm.layoutVM?.model)
                }
                .frame(maxWidth: .infinity)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                
                if let footerVM = vm.footerVM {
                    BotsiFooterBlockView(viewModel: footerVM)
                }
            }
            .withScreenSize(CGSize(width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
                                   height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom))
        }
        .if(vm.heroImage?.style != .transparent, transform: {
            $0
                .backgroundFill(vm.layoutVM?.fillColor)
        })
    }
}

@available(iOS 15.0, *)
private extension BotsiPaywallScreen {
    
    func ContentScroll(height: CGFloat) -> some View {
        NonBouncingScrollView {
            VStack(spacing: 0) {
                if vm.heroImage?.style == .overlay {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: height * ((vm.heroImage?.heightPercent ?? 0.3) - 0.01))
                }
                VStack(spacing: vm.layoutVM?.spacing) {
                    if vm.heroImage?.style == .flat {
                        let horizontalPadding = vm.heroHorizontalPadding
                        let verticalPadding = vm.heroVerticalPadding
                        VStack {
                            GeometryReader { geometry in
                                BotsiHeroImageView(model: vm.heroImage!)
                                    .frame(
                                        width: geometry.size.width - horizontalPadding,
                                        height: geometry.size.height - verticalPadding
                                    )
                                    .clipped()
                                    .applyBotsiMask(vm.heroImage?.shape)
                            }
                        }
                        .frame(height: height * (vm.heroImage?.heightPercent ?? 0.3))
                        .padding(.leading, vm.heroImage?.layout.padding.left)
                        .padding(.top, (vm.heroImage?.layout.padding.top ?? 0) + 10)
                        .padding(.trailing, vm.heroImage?.layout.padding.right)
                        .padding(.bottom, vm.heroImage?.layout.padding.bottom)
                        .offset(y: vm.heroImage?.layout.verticalOffset.toCGFloat() ?? 0)
                    }
                    ForEach(vm.contentBlocks, id: \.meta.id) { block in
                        BotsiBlockRendererView(block: block) { action in
                            print("KA: \(action)")
                        }
                    }
                }
                .padding(.leading, vm.layoutVM?.padding.left)
                .padding(.top, vm.layoutVM?.padding.top)
                .padding(.trailing, vm.layoutVM?.padding.right)
                .padding(.bottom, vm.layoutVM?.padding.bottom)
                .if(vm.heroImage?.style != .transparent) {
                    $0.backgroundFill(vm.layoutVM?.fillColor)
                }
            }
        }
    }
    
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
