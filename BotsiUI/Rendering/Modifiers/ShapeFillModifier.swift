//
//  ShapeFillModifier.swift
//  Botsi
//
//  Created by Konstantin on 15.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
private struct ShapeFillModifier<S: Shape>: ViewModifier {
    let shape: S
    let fill: BotsiFillColor?

    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if let fill = fill {
                        switch fill {
                        case .solid(let color):
                            shape.fill(color)
                        case .gradient(let gradient):
                            shape.fill(gradient)
                        }
                    } else {
                        shape.fill(Color.clear)
                    }
                }
            )
    }
}

@available(iOS 15.0, *)
public extension View where Self: Shape {
    func shapeFill(_ fill: BotsiFillColor?) -> some View {
        modifier(ShapeFillModifier(shape: self, fill: fill))
    }
}
