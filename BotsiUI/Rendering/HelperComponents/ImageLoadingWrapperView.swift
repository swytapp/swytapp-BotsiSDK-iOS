//
//  ImageLoadingWrapperView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 24.10.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct ImageLoadingWrapperView<Content: View>: View {
    let content: Content
    let onImagesLoaded: () -> Void
    @State private var imageLoadingStates: [String: Bool] = [:]
    @State private var hasNotified = false
    
    var body: some View {
        content
            .environment(\.imageLoadingTracker, ImageLoadingTracker(
                onImageStart: { url in
                    Task { @MainActor in
                        imageLoadingStates[url] = false
                    }
                },
                onImageComplete: { url in
                    Task { @MainActor in
                        imageLoadingStates[url] = true
                        checkAllImagesLoaded()
                    }
                }
            ))
    }
    
    private func checkAllImagesLoaded() {
        guard !hasNotified else { return }
        guard !imageLoadingStates.isEmpty else { return }
        guard imageLoadingStates.values.allSatisfy({ $0 }) else { return }
        
        hasNotified = true
        onImagesLoaded()
    }
}

@available(iOS 15.0, *)
struct ImageLoadingTracker: Sendable {
    let onImageStart: @Sendable (String) -> Void
    let onImageComplete: @Sendable (String) -> Void
}

@available(iOS 15.0, *)
struct ImageLoadingTrackerKey: EnvironmentKey {
    static let defaultValue = ImageLoadingTracker(
        onImageStart: { _ in },
        onImageComplete: { _ in }
    )
}

@available(iOS 15.0, *)
extension EnvironmentValues {
    var imageLoadingTracker: ImageLoadingTracker {
        get { self[ImageLoadingTrackerKey.self] }
        set { self[ImageLoadingTrackerKey.self] = newValue }
    }
}
