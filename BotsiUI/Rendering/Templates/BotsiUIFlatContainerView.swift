//
//  BotsiUIFlatContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//

#if canImport(UIKit)

import Botsi
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct BotsiUIFlatContainerView: View {
    @State
    private var footerSize: CGSize = .zero
    
    @State
    private var drawFooterBackground = false

    var screen: VC.Screen

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

    var body: some View {
        GeometryReader { globalProxy in
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack {
                        BotsiUIElementView(screen.content)
                            .frame(maxWidth: .infinity)

                        FooterVerticalFillerView(height: footerSize.height) { frame in
                            withAnimation {
                                drawFooterBackground = frame.maxY > globalProxy.size.height + globalProxy.safeAreaInsets.bottom
                            }
                        }
                    }
                }
                .scrollIndicatorsHidden_compatible()

                if let footer = screen.footer {
                    footerView(footer, globalProxy: globalProxy)
                        .onGeometrySizeChange { footerSize = $0 }
                }

                if let overlay = screen.overlay {
                    BotsiUIElementView(overlay)
                }
            }
            .ignoresSafeArea()
        }
        .coordinateSpace(name: CoordinateSpace.botsiGlobalName)
    }
}

#endif
