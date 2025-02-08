//
//  BotsiUIBasicContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//
#if canImport(UIKit)

import Botsi
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension CoordinateSpace {
    static let botsiBasicName = "botsi.container.basic"
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct BotsiUIBasicContainerView: View {
    @EnvironmentObject
    private var paywallViewModel: BotsiPaywallViewModel
    @Environment(\.botsiScreenSize)
    private var screenSize: CGSize
    @Environment(\.botsiSafeAreaInsets)
    private var safeArea: EdgeInsets
    @State
    private var footerSize: CGSize = .zero
    @State
    private var drawFooterBackground = false

    var screen: VC.Screen

    var body: some View {
        GeometryReader { globalProxy in
            ZStack(alignment: .bottom) {
                if let coverBox = screen.cover, let coverContent = coverBox.content {
                    ScrollView {
                        VStack(spacing: 0) {
                            coverView(
                                coverBox,
                                coverContent,
                                nil
                            )

                            contentView(
                                content: screen.content,
                                coverBox: coverBox,
                                globalProxy: globalProxy
                            )
                        }
                    }
                    .ignoresSafeArea()
                    .scrollIndicatorsHidden_compatible()
                } else {
                    EmptyView()
                        .onAppear {
                            paywallViewModel.eventsHandler.event_didFailRendering(
                                with: .wrongComponentType("screen.cover")
                            )
                        }
                }

                if let footer = screen.footer {
                    footerView(footer, globalProxy: globalProxy)
                        .onGeometrySizeChange { footerSize = $0 }
                }

                if let overlay = screen.overlay {
                    BotsiUIElementView(overlay)
                }
            }
            .coordinateSpace(name: CoordinateSpace.botsiBasicName)
            .ignoresSafeArea()
        }
        .coordinateSpace(name: CoordinateSpace.botsiGlobalName)
    }

    @ViewBuilder
    func coverView(
        _ box: VC.Box,
        _ content: VC.Element,
        _ properties: VC.Element.Properties?
    ) -> some View {
        let height: CGFloat = {
            if let boxHeight = box.height, case let .fixed(unit) = boxHeight {
                return unit.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom)
            } else {
                return 0.0
            }
        }()

        GeometryReader { p in
            let minY = p.frame(in: .named(CoordinateSpace.botsiBasicName)).minY
            let isScrollingDown = minY > 0
            let isScrollingUp = minY < 0
            let scale = max(1.0, 1.0 + minY / p.size.height)

            BotsiUIElementView(content)
                .frame(
                    width: p.size.width,
                    height: {
                        if isScrollingDown {
                            return height + minY
                        } else {
                            return height
                        }
                    }()
                )
                .scaleEffect(x: scale, y: scale, anchor: .center)
                .clipped()
                .offset(
                    y: {
                        if isScrollingUp {
                            return -minY / 2.0
                        } else if isScrollingDown {
                            return -minY
                        } else {
                            return 0.0
                        }
                    }()
                )
        }
        .frame(height: height)
    }

    @ViewBuilder
    func contentView(
        content: VC.Element,
        coverBox: VC.Box,
        globalProxy: GeometryProxy
    ) -> some View {
        let bottomOverscrollHeight = screenSize.height
        let properties = content.properties
        let offsetY = properties?.offset.y ?? 0

        VStack(spacing: 0) {
            BotsiUIElementWithoutPropertiesView(content)

            FooterVerticalFillerView(height: footerSize.height) { frame in
                withAnimation {
                    drawFooterBackground = frame.maxY > globalProxy.size.height + globalProxy.safeAreaInsets.bottom
                }
            }
        }
        .padding(.bottom, bottomOverscrollHeight - offsetY)
        .applyingProperties(properties, includeBackground: true)
        .padding(.bottom, offsetY - bottomOverscrollHeight)
    }

    @ViewBuilder
    private func footerView(
        _ element: VC.Element,
        globalProxy: GeometryProxy
    ) -> some View {
        if footerSize.height >= globalProxy.size.height {
            ScrollView {
                BotsiUIElementView(element, drawDecoratorBackground: drawFooterBackground)
            }
            .scrollIndicatorsHidden_compatible()
        } else {
            BotsiUIElementView(element, drawDecoratorBackground: drawFooterBackground)
        }
    }
}

#endif
