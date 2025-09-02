//
//  BackgroundFillModifire.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 04.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BackgroundFillModifier: ViewModifier {
    let fill: BotsiFillColor?
    
    public func body(content: Content) -> some View {
        content.background(backgroundView)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch fill {
        case .solid(let color):
            color
        case .gradient(let gradient):
            gradient
        case .none:
            Color.clear
        }
    }
}

@available(iOS 15.0, *)
public extension View {
    func backgroundFill(_ fill: BotsiFillColor?) -> some View {
        self.modifier(BackgroundFillModifier(fill: fill))
    }
}
