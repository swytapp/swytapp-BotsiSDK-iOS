//
//  ForegroundColorModifier.swift
//  Botsi
//
//  Created by Konstantin on 20.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
private struct ForegroundFillModifier: ViewModifier {
    let fill: BotsiFillColor?

    func body(content: Content) -> some View {
        switch fill {
        case .solid(let color):
            content.foregroundColor(color)
        default:
            content
        }
    }
}

@available(iOS 15.0, *)
public extension Text {
    func foregroundFill(_ fill: BotsiFillColor?) -> some View {
        self.modifier(ForegroundFillModifier(fill: fill))
    }
}
