//
//  BotsiUITransparentContainerView.swift
//
//
//  Created by Aleksey Goncharov on 03.05.2024.
//

#if canImport(UIKit)

import Botsi
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct BotsiUITransparentContainerView: View {
    var screen: VC.Screen

    @State var footerSize: CGSize = .zero

    @ViewBuilder
    private func scrollableFooterView(
        _ element: VC.Element,
        globalProxy: GeometryProxy
    ) -> some View {
        let additionalTopPadding = max(0, globalProxy.size.height - footerSize.height + globalProxy.safeAreaInsets.top + globalProxy.safeAreaInsets.bottom)

        ScrollViewReader { scrollProxy in
            ScrollView {
                if additionalTopPadding > 0.0 {
                    BotsiUIElementView(element)
                        .id("content")
                        .onGeometrySizeChange { footerSize = $0 }
                        .padding(.top, additionalTopPadding)
                } else {
                    BotsiUIElementView(element)
                        .id("content")
                        .onGeometrySizeChange { footerSize = $0 }
                }
            }
            .scrollIndicatorsHidden_compatible()
            .onAppear {
                DispatchQueue.main.async {
                    scrollProxy.scrollTo("content", anchor: .bottom)
                }
            }
        }
    }

    var body: some View {
        GeometryReader { p in
            ZStack(alignment: .bottom) {
                BotsiUIElementView(screen.content)

                if let footer = screen.footer {
                    scrollableFooterView(
                        footer,
                        globalProxy: p
                    )
                }

                if let overlay = screen.overlay {
                    BotsiUIElementView(overlay)
                }
            }
            .ignoresSafeArea()
        }
    }
}

#endif
