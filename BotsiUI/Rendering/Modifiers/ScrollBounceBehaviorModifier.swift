//
//  ScrollBounceBehaviorModifier.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 08.10.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public extension View {
    @ViewBuilder
    func scrollBounceBehavior() -> some View {
        if #available(iOS 16.4, *) {
            self.scrollBounceBehavior(.basedOnSize)
        } else {
            self
        }
    }
}
