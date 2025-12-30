//
//  BotsiUISafeAreaEnvironment.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 29.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiUISafeAreaEnvironmentKey: EnvironmentKey {
    static let defaultValue: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
}

@available(iOS 15.0, *)
extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        get { self[BotsiUISafeAreaEnvironmentKey.self] }
        set { self[BotsiUISafeAreaEnvironmentKey.self] = newValue }
    }
}

@available(iOS 15.0, *)
extension View {
    func withSafeArea(_ value: EdgeInsets) -> some View {
        return environment(\.safeAreaInsets, value)
    }
}
