//
//  BotsiPaywallScreen.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 19.06.2025.
//

import SwiftUI
import Botsi

@available(iOS 15.0, *)
public struct BotsiPaywallScreen: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var paywallViewModel: BotsiPaywallViewModel
    @StateObject private var productViewModel: BotsiProductViewModel
    @StateObject private var actionHandler: PaywallActionHandler
    @State private var footerHeight: CGFloat = 0
    @State private var areImagesLoaded = false
    
    public init(viewModel: BotsiPaywallViewModel, paywall: BotsiPaywall) {
        let actionHandler = PaywallActionHandler(onAction: viewModel.handleAction, timerProvider: viewModel.timerProvider)
        _paywallViewModel = .init(wrappedValue: viewModel)
        _actionHandler = .init(wrappedValue: actionHandler)
        _productViewModel = .init(wrappedValue: BotsiProductViewModel(actionHandler: actionHandler, paywall: paywall))
    }
    
    public var body: some View {
        ZStack {
            ImageLoadingWrapperView(
                content: paywallContent,
                onImagesLoaded: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        areImagesLoaded = true
                    }
                }
            )
            
            Group {
                if !areImagesLoaded {
                    BotsiUILoadingView()
                        .background(Color(uiColor: .systemBackground))
                        .ignoresSafeArea()
                }
            }
            .transition(.move(edge: .bottom))
            .zIndex(1)
        }
    }
    
    @ViewBuilder
    private var paywallContent: some View {
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
                .overlay {
                    bottomSheetOverlay
                }
                .if(paywallViewModel.heroImage?.style != .transparent, transform: {
                    $0.backgroundFill(paywallViewModel.layoutVM?.fillColor)
                })
                .withChildPadding(paywallViewModel.layoutVM?.padding ?? .defaultEdge)
                .withScreenSize(screenSize(for: proxy))
                .withSafeArea(proxy.safeAreaInsets)
                .ignoresSafeArea()
            }
            
            if productViewModel.isLoading {
                BotsiUILoadingView()
            }
        }
        .onAppear {
            actionHandler.handleAction(.didOpen)
        }
        .onChange(of: paywallViewModel.shouldDismiss) { shouldDismiss in
            dismiss()
        }
        .environmentObject(actionHandler)
        .environmentObject(productViewModel)
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
        if let heroImage = paywallViewModel.heroImage {
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
        .backgroundFill(paywallViewModel.layoutVM?.fillColor)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func flatHeroImageIfNeeded(_ proxy: GeometryProxy) -> some View {
        if let heroImage = paywallViewModel.heroImage, heroImage.style == .flat {
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
        let horizontalPadding = paywallViewModel.heroHorizontalPadding
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                overlaySpacerIfNeeded(proxy)
                mainContent(proxy)
                footerFiller
                
                Spacer(minLength: 0)
            }
        }
        .scrollBounceBehavior()
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    var footerFiller: some View {
        FooterPaddingFillerView(height: footerHeight)
    }
    
    @ViewBuilder
    func mainContent(_ proxy: GeometryProxy) -> some View {
        VStack(spacing: paywallViewModel.layoutVM?.spacing) {
            flatHeroImageIfNeeded(proxy)
            contentBlocks
        }
        .padding(paywallViewModel.layoutVM?.padding)
        .if(paywallViewModel.containsTopButtons) {
            $0.padding(.top, 30)
        }
        .if(paywallViewModel.heroImage?.style != .transparent) {
            $0.backgroundFill(paywallViewModel.layoutVM?.fillColor)
        }
        .if(paywallViewModel.heroImage?.style == .overlay) {
            $0.mask(with: paywallViewModel.heroImage?.shape, isContainer: true)
        }
    }
    
    @ViewBuilder
    var contentBlocks: some View {
        ForEach(paywallViewModel.contentBlocks, id: \.meta.id) { block in
            BotsiBlockRendererView(block: block)
                .padding(block.content?.padding)
        }
    }
    
    @ViewBuilder
    func overlaySpacerIfNeeded(_ proxy: GeometryProxy) -> some View {
        if paywallViewModel.heroImage?.style == .overlay {
            Rectangle()
                .fill(.clear)
                .frame(height: screenSize(for: proxy).height * (paywallViewModel.heroImage?.heightPercent ?? 0.3))
        }
    }
}

// MARK: - Top Buttons
@available(iOS 15.0, *)
private extension BotsiPaywallScreen {
    
    @ViewBuilder
    func topButtons(with padding: CGFloat) -> some View {
        if let buttons = paywallViewModel.layoutVM?.model.buttons, !buttons.isEmpty {
            TopButtonsOverlayView(buttons: buttons)
                .padding(.top, padding)
        }
    }
}

// MARK: - Footer
@available(iOS 15.0, *)
private extension BotsiPaywallScreen {
    
    var footerContent: some View {
        paywallViewModel.footerVM.map { footerVM in
            BotsiFooterBlockView(model: footerVM) { height in
                footerHeight = height
            }
        }
    }
}

// MARK: - Bottom Sheet
@available(iOS 15.0, *)
private extension BotsiPaywallScreen {
    
    @ViewBuilder
    var bottomSheetOverlay: some View {
        if productViewModel.isBottomProductSheetPresented,
           let productBlock = paywallViewModel.contentBlocks.first(where: { $0.meta.type == .products }),
           case .products(let model) = productBlock.content,
           let sheet = BotsiViewFactory.makeBottomSheet(model: model, block: productBlock) {
            sheet
                .transition(.move(edge: .bottom))
        }
    }
}
