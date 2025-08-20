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
        GeometryReader { proxy in
            VStack {
                ZStack {
                    heroContent(proxy)
                    scrollContent(proxy)
                    topButtons()
                }
                .frame(maxWidth: .infinity)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                
                footerContent
            }
            .withScreenSize(screenSize(for: proxy))
        }
        .if(vm.heroImage?.style != .transparent, transform: {
            $0.backgroundFill(vm.layoutVM?.fillColor)
        })
    }
}

// MARK: - Computed Properties
@available(iOS 15.0, *)
private extension BotsiPaywallScreen {
    
    var footerContent: some View {
        vm.footerVM.map(BotsiFooterBlockView.init)
    }
    
    func screenSize(for proxy: GeometryProxy) -> CGSize {
        CGSize(
            width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
            height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
        )
    }
}

// MARK: - Hero Content
@available(iOS 15.0, *)
private extension BotsiPaywallScreen {
    
    @ViewBuilder
    func heroContent(_ proxy: GeometryProxy) -> some View {
        if let heroImage = vm.heroImage {
            switch heroImage.style {
            case .transparent:
                BotsiHeroImageView(model: heroImage)
            case .overlay:
                overlayHeroContent(heroImage, proxy: proxy)
            case .flat:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private func overlayHeroContent(_ heroImage: BotsiHeroImageModel, proxy: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            BotsiHeroImageView(model: heroImage)
                .frame(height: proxy.size.height * heroImage.heightPercent)
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .backgroundFill(vm.layoutVM?.fillColor)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func flatHeroImageIfNeeded(_ proxy: GeometryProxy) -> some View {
        if let heroImage = vm.heroImage, heroImage.style == .flat {
           let imageSize = calculateImageSize(for: heroImage, proxy: proxy)
            
            VStack {
                BotsiHeroImageView(model: heroImage)
                    .frame(height: imageSize.height)
                    .if(shouldConstrainToSquare(heroImage, size: imageSize)) {
                        $0.frame(width: imageSize.height, height: imageSize.height)
                    }
                    .mask(with: heroImage.shape, size: imageSize)
            }
            .padding(heroImage.layout.padding)
            .offset(y: heroImage.layout.verticalOffset.toCGFloat() ?? 0)
        }
    }
    
    private func calculateImageSize(for heroImage: BotsiHeroImageModel, proxy: GeometryProxy) -> CGSize {
        let horizontalPadding = vm.heroHorizontalPadding
        let height = screenSize(for: proxy).height * heroImage.heightPercent
        let width = screenSize(for: proxy).width - horizontalPadding
        return CGSize(width: width, height: height)
    }
    
    private func shouldConstrainToSquare(_ heroImage: BotsiHeroImageModel, size: CGSize) -> Bool {
        heroImage.shape == .circle && size.height <= size.width
    }
}

// MARK: - Scroll Content
@available(iOS 15.0, *)
private extension BotsiPaywallScreen {
    
    func scrollContent(_ proxy: GeometryProxy) -> some View {
        NonBouncingScrollView {
            VStack(spacing: 0) {
                overlaySpacerIfNeeded(proxy)
                mainContent(proxy)
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func mainContent(_ proxy: GeometryProxy) -> some View {
        VStack(spacing: vm.layoutVM?.spacing) {
            flatHeroImageIfNeeded(proxy)
            contentBlocks
        }
        .padding(.top, 20)
        .padding(vm.layoutVM?.padding)
        .if(vm.heroImage?.style != .transparent) {
            $0.backgroundFill(vm.layoutVM?.fillColor)
        }
        .if(vm.heroImage?.style == .overlay) {
            $0.mask(with: vm.heroImage?.shape, isContainer: true)
        }
    }
    
    @ViewBuilder
    private var contentBlocks: some View {
        ForEach(vm.contentBlocks, id: \.meta.id) { block in
            BotsiBlockRendererView(block: block) { action in
                print("KA: \(action)")
            }
            .padding(block.content?.padding)
        }
    }
    
    @ViewBuilder
    func overlaySpacerIfNeeded(_ proxy: GeometryProxy) -> some View {
        if vm.heroImage?.style == .overlay {
            Rectangle()
                .fill(.clear)
                .frame(height: screenSize(for: proxy).height * (vm.heroImage?.heightPercent ?? 0.3))
        }
    }
}

// MARK: - Top Buttons
@available(iOS 15.0, *)
private extension BotsiPaywallScreen {
    
    @ViewBuilder
    func topButtons() -> some View {
        if let buttons = vm.layoutVM?.model.buttons, !buttons.isEmpty {
            TopButtonsOverlayView(buttons: buttons) { action in
                dismiss()
            }
        }
    }
}
