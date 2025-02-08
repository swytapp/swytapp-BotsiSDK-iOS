//
//  BotsiUIBackgroundModifier.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Botsi
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct BotsiUIBackgroundModifier: ViewModifier {
    var background: VC.Background?

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    func body(content: Content) -> some View {
        switch self.background {
        case .image(let imageData):
            content
                .background {
                    BotsiUIImageView(
                        asset: imageData.of(self.colorScheme),
                        aspect: .fill,
                        tint: nil
                    )
                    .ignoresSafeArea()
                }
        default:
            content
                .background {
                    Rectangle()
                        .fill(
                            background: self.background,
                            colorScheme: self.colorScheme
                        )
                        .ignoresSafeArea()
                }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func decorate(with background: VC.Background?) -> some View {
        if let background {
            modifier(BotsiUIBackgroundModifier(background: background))
        } else {
            self
        }
    }
}

#endif
