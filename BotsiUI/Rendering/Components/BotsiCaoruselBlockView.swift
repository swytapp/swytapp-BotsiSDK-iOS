//
//  BotsiCaoruselBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiCarouselBlockView: View {
    
    let block: BotsiPaywallBlock
    let model: BotsiCarouselModel
    
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isInteracting: Bool = false
    @State private var autoScrollTimer: Timer?
    @State private var itemWidth: CGFloat = 0
    @State private var totalChildren: Int = 0
    
    private var additionalPadding: CGFloat {
        return model.style.placement == .outside ? 16 : 0
    }
    
    @Environment(\.childPadding) private var childPadding
    @Environment(\.screenSize) private var screenSize
    
    private var springAnimation: Animation {
        .spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1)
    }
    
    public var body: some View {
        let additionalPadding = model.style.placement == .outside ? model.style.padding.vertical + 8 : 0
        Group {
            if model.style.placement == .outside {
                VStack(spacing: 0) {
                    carouselContent
                    Spacer().frame(height: additionalPadding)
                        .overlay(alignment: .center) {
                            paginationIndicators
                        }
                }
            } else {
                carouselContent
                    .overlay(alignment: .bottom) {
                        paginationIndicators
                            .padding(.bottom, model.style.padding.bottom)
                    }
            }
        }
        .frame(height: model.height + additionalPadding)
        .onAppear {
            if let children = block.children {
                totalChildren = children.count
                
                let totalHorizontalPadding = childPadding.horizontal + model.padding.horizontal
                itemWidth = screenSize.width - totalHorizontalPadding
            }
            startAutoScroll()
        }
        .background(backgroundImageView)
        .offset(y: model.verticalOffset)
        .onDisappear {
            stopAutoScroll()
        }
    }
}

// MARK: - Background Image
@available(iOS 15.0, *)
private extension BotsiCarouselBlockView {
    @ViewBuilder
    var backgroundImageView: some View {
        BotsiImageBlockView(url: model.backgroundImage,
                            aspect: .stretch)
    }
}

// MARK: - Carousel Content
@available(iOS 15.0, *)
private extension BotsiCarouselBlockView {
    @ViewBuilder
    var carouselContent: some View {
        GeometryReader { proxy in
            let hPadding = (proxy.size.width - itemWidth) / 2.0
            
            if let children = block.children {
                HStack(spacing: model.spacing) {
                    ForEach(Array(children.enumerated()), id: \.element.meta.id) { index, childBlock in
                        BotsiBlockRendererView(block: childBlock)
                            .frame(width: itemWidth, height: model.height)
                            .padding(.leading, index == 0 ? hPadding : 0)
                            .padding(.trailing, index == children.count - 1 ? hPadding : 0)
                            .onTapGesture {
                                handleUserInteraction()
                                withAnimation(springAnimation) {
                                    currentIndex = index
                                }
                            }
                    }
                }
                .frame(height: model.height)
                .offset(x: CGFloat(-currentIndex) * (itemWidth + model.spacing) + dragOffset)
                .simultaneousGesture(dragGesture)
                .onAppear {
                    totalChildren = children.count
                }
                .onChange(of: screenSize.width) { _ in
                    let totalHorizontalPadding = childPadding.horizontal + model.padding.horizontal
                    itemWidth = screenSize.width - totalHorizontalPadding
                }
            }
        }
    }
}

// MARK: - Drag Gesture
@available(iOS 15.0, *)
private extension BotsiCarouselBlockView {
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard model.timing.interactive != .nonInteractive else { return }
                
                if !isInteracting {
                    isInteracting.toggle()
                    stopAutoScroll()
                }
                
                dragOffset = value.translation.width
            }
            .onEnded { value in
                guard model.timing.interactive != .nonInteractive else { return }
                
                let translation = value.translation.width
                let threshold = itemWidth / 4
                
                withAnimation(springAnimation) {
                    if abs(translation) > threshold {
                        if translation > 0 && currentIndex > 0 {
                            currentIndex -= 1
                        } else if translation < 0 && currentIndex < totalChildren - 1 {
                            currentIndex += 1
                        }
                    }
                    dragOffset = 0
                }
                
                handleUserInteraction()
                isInteracting = false
            }
    }
}

// MARK: - Pagination Indicators
@available(iOS 15.0, *)
private extension BotsiCarouselBlockView {
    @ViewBuilder
    var paginationIndicators: some View {
        if model.pageControl && totalChildren > 1 {
            HStack(spacing: model.style.spacing) {
                ForEach(0..<totalChildren, id: \.self) { index in
                    paginationDot(for: index)
                }
            }
            .padding(.leading, model.style.padding.left)
            .padding(.trailing, model.style.padding.right)
        }
    }
    
    func paginationDot(for index: Int) -> some View {
        let isActive = currentIndex == index
        let dotSize = model.style.size
        
        return Circle()
            .fill(isActive ? model.style.activeColor.toColor() : model.style.defaultColor.toColor())
            .frame(width: dotSize, height: dotSize)
            .scaleEffect(isActive ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: currentIndex)
            .onTapGesture {
                guard index != currentIndex, model.timing.interactive != .nonInteractive else { return }
                handleUserInteraction()
                withAnimation(springAnimation) {
                    currentIndex = index
                }
            }
    }
}

// MARK: - Auto Scroll
@available(iOS 15.0, *)
private extension BotsiCarouselBlockView {
    func startAutoScroll() {
        guard model.slideShow, !isInteracting else { return }
        
        stopAutoScroll()
        
        let initialDelay = Double(model.timing.initialTiming / 1000)
        let interval = Double(model.timing.timing / 1000) + 0.4 // Add animation duration
        
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: initialDelay, repeats: false) { _ in
            Task { @MainActor in
                scheduleAutoScroll(interval: interval)
            }
        }
    }
    
    func scheduleAutoScroll(interval: Double) {
        guard model.slideShow, !isInteracting, totalChildren > 0 else { return }
        
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task { @MainActor in
                guard !isInteracting else { return }
                
                if currentIndex < totalChildren - 1 {
                    withAnimation(springAnimation) {
                        currentIndex += 1
                    }
                } else {
                    switch model.timing.lastOption {
                    case .startOver:
                        withAnimation(springAnimation) {
                            currentIndex = 0
                        }
                    case .stop:
                        stopAutoScroll()
                    }
                }
            }
        }
    }
    
    func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    func handleUserInteraction() {
        guard model.slideShow else { return }
        
        switch model.timing.interactive {
        case .nonInteractive:
            return
        case .pause:
            stopAutoScroll()
            let resumeDelay = Double(model.timing.timing / 1000)
            DispatchQueue.main.asyncAfter(deadline: .now() + resumeDelay) {
                startAutoScroll()
            }
        case .stop:
            stopAutoScroll()
        }
    }
}
