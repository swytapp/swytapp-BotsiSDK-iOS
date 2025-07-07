//
//  BackgroundFillModifire.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 04.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
private struct BackgroundFillModifier: ViewModifier {
    let fill: BotsiFillColor?

    func body(content: Content) -> some View {
        ZStack {
            switch fill {
            case .solid(let color):
                color
            case .gradient(let gradient):
                gradient
            default:
                Color.clear
            }
            content
        }
    }
}

@available(iOS 15.0, *)
public extension View {
    func backgroundFill(_ fill: BotsiFillColor?) -> some View {
        self.modifier(BackgroundFillModifier(fill: fill))
    }
}
