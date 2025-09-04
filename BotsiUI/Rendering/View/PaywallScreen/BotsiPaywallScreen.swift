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
    @StateObject private var actionHandler: PaywallActionHandler
    @State private var footerHeight: CGFloat = 0
    
    public init(viewModel: BotsiPaywallViewModel) {
        _vm = .init(wrappedValue: viewModel)
        _actionHandler = .init(wrappedValue: PaywallActionHandler(paywall: viewModel))
    }
    
    public var body: some View {
        CustomGeometryReaderView { size in
            GeometryReader { proxy in
                VStack {
                    ZStack {
                        topButtons(with: proxy.safeAreaInsets.top)
                        heroContent(proxy)
                        scrollContent(proxy)
                    }
                    .frame(maxWidth: .infinity)
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                }
                .overlay(alignment: .top) {
                    topButtons(with: proxy.safeAreaInsets.top)
                }
                .overlay(alignment: .bottom) {
                    footerContent
                }
                .if(vm.heroImage?.style != .transparent, transform: {
                    $0.backgroundFill(vm.layoutVM?.fillColor)
                })
                .withScreenSize(screenSize(for: proxy))
                .withSafeArea(proxy.safeAreaInsets)
                .ignoresSafeArea()
            }
        }
        .environmentObject(actionHandler)
        .onChange(of: vm.shouldDismiss) { shouldDismiss in
            dismiss()
        }
    }
    
    private func screenSize(for proxy: GeometryProxy) -> CGSize {
        CGSize(width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
               height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom)
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
    func overlayHeroContent(_ heroImage: BotsiHeroImageModel, proxy: GeometryProxy) -> some View {
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
                    .if(shouldConstrainToCircle(heroImage, size: imageSize)) {
                        $0.frame(width: imageSize.height, height: imageSize.height)
                    }
                    .mask(with: heroImage.shape, size: imageSize)
            }
            .padding(heroImage.layout.padding)
            .offset(y: heroImage.layout.verticalOffset.toCGFloat() ?? 0)
        }
    }
    
    func calculateImageSize(for heroImage: BotsiHeroImageModel, proxy: GeometryProxy) -> CGSize {
        let horizontalPadding = vm.heroHorizontalPadding
        let height = screenSize(for: proxy).height * heroImage.heightPercent
        let width = screenSize(for: proxy).width - horizontalPadding
        return CGSize(width: width, height: height)
    }
    
    func shouldConstrainToCircle(_ heroImage: BotsiHeroImageModel, size: CGSize) -> Bool {
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
                footerFiller
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    var footerFiller: some View {
        FooterPaddingFillerView(height: footerHeight)
    }
    
    @ViewBuilder
    func mainContent(_ proxy: GeometryProxy) -> some View {
        VStack(spacing: vm.layoutVM?.spacing) {
            flatHeroImageIfNeeded(proxy)
            contentBlocks
        }
        .padding(vm.layoutVM?.padding)
        .if(vm.heroImage?.style != .transparent) {
            $0.backgroundFill(vm.layoutVM?.fillColor)
        }
        .if(vm.heroImage?.style == .overlay) {
            $0.mask(with: vm.heroImage?.shape, isContainer: true)
        }
    }
    
    @ViewBuilder
    var contentBlocks: some View {
        ForEach(vm.contentBlocks, id: \.meta.id) { block in
            BotsiBlockRendererView(block: block)
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
    func topButtons(with padding: CGFloat) -> some View {
        if let buttons = vm.layoutVM?.model.buttons, !buttons.isEmpty {
            TopButtonsOverlayView(buttons: buttons)
                .padding(.top, padding)
        }
    }
}

// MARK: - Footer
@available(iOS 15.0, *)
private extension BotsiPaywallScreen {
    
    var footerContent: some View {
        vm.footerVM.map { footerVM in
            BotsiFooterBlockView(model: footerVM) { height in
                footerHeight = height
            }
        }
    }
}
