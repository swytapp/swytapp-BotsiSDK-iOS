//
//  StyledContainerModifier.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 22.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct StyledContainerModifier: ViewModifier {
    let fillColor: BotsiFillColor?
    let borderColor: BotsiFillColor?
    let borderThickness: CGFloat
    let cornerRadius: CGFloat
    
    public func body(content: Content) -> some View {
        content
            .backgroundFill(fillColor, cornerRadius: cornerRadius)
            .if(fillColor?.isGradient != true) { view in
                view
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor?.toColor() ?? .clear, lineWidth: borderThickness)
                    .ignoresSafeArea()
            )
    }
}

@available(iOS 15.0, *)
public extension View {
    func styledContainer(fillColor: BotsiFillColor?, borderColor: BotsiFillColor?, borderThickness: CGFloat, cornerRadius: CGFloat) -> some View {
        modifier(StyledContainerModifier(fillColor: fillColor, borderColor: borderColor, borderThickness: borderThickness, cornerRadius: cornerRadius))
    }
}
