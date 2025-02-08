//
//  BotsiUIFixedFrameModifier.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import Botsi
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct BotsiUIFixedFrameModifier: ViewModifier {
    @Environment(\.botsiScreenSize)
    private var screenSize: CGSize
    @Environment(\.botsiSafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    var box: VC.Box

    func body(content: Content) -> some View {
        let alignment = Alignment.from(
            horizontal: box.horizontalAlignment.swiftuiValue(with: layoutDirection),
            vertical: box.verticalAlignment.swiftuiValue
        )

        switch (box.width, box.height) {
        case let (.fixed(w), .fixed(h)):
            content.frame(width: w.points(screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing),
                          height: h.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom),
                          alignment: alignment)
        case let (.fixed(w), _):
            content.frame(width: w.points(screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing),
                          height: nil,
                          alignment: alignment)
        case let (_, .fixed(h)):
            content.frame(width: nil,
                          height: h.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom),
                          alignment: alignment)
        default:
            content
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    func fixedFrame(box: VC.Box) -> some View {
        modifier(BotsiUIFixedFrameModifier(box: box))
    }
}

#endif
