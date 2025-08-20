//
//  BotsiUIScreenSizeEnvironment.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 15.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiUIScreenSizeEnvironmentKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

@available(iOS 15.0, *)
extension EnvironmentValues {
    var screenSize: CGSize {
        get { self[BotsiUIScreenSizeEnvironmentKey.self] }
        set { self[BotsiUIScreenSizeEnvironmentKey.self] = newValue }
    }
}

@available(iOS 15.0, *)
extension View {
    func withScreenSize(_ value: CGSize) -> some View {
        return environment(\.screenSize, value)
    }
}
