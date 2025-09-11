//
//  BotsiUIChildPaddingEnvironmentKey.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 29.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiUIChildPaddingEnvironmentKey: EnvironmentKey {
    static let defaultValue: BotsiEdge = .defaultEdge
}

@available(iOS 15.0, *)
extension EnvironmentValues {
    var childPadding: BotsiEdge {
        get { self[BotsiUIChildPaddingEnvironmentKey.self] }
        set { self[BotsiUIChildPaddingEnvironmentKey.self] = newValue }
    }
}

@available(iOS 15.0, *)
extension View {
    func withChildPadding(_ value: BotsiEdge) -> some View {
        return environment(\.childPadding, value)
    }
}
