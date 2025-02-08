//
//  FooterVerticalFillerView.swift
//
//
//  Created by Aleksey Goncharov on 25.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension CoordinateSpace {
    static let botsiGlobalName = "botsi.container.global"
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct BotsiUIGeometryFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct FooterVerticalFillerView: View {
    var height: Double
    var onFrameChange: (CGRect) -> Void

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .frame(height: height)
                .preference(key: BotsiUIGeometryFramePreferenceKey.self, value: proxy.frame(in: .named(CoordinateSpace.botsiGlobalName)))
                .onPreferenceChange(BotsiUIGeometryFramePreferenceKey.self) { value in
                    Task { @MainActor in
                        onFrameChange(value)
                    }
                }
        }
        .frame(height: height)
    }
}

#endif
