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
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        switch fill {
        case .solid(let color):
            content
                .background(color)
        case .gradient(let gradient):
            content
                .background(
                    gradient
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .ignoresSafeArea()
                )
        default:
            Color.clear
        }
    }
}

@available(iOS 15.0, *)
public extension View {
    func backgroundFill(_ fill: BotsiFillColor?, cornerRadius: CGFloat = 0) -> some View {
        self.modifier(BackgroundFillModifier(fill: fill, cornerRadius: cornerRadius))
    }
}
