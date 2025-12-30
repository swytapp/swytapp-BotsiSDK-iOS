//
//  SwiftUIView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 20.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct RoundedCorners: Shape {
    let cornerRadius: CGFloat
    let corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}
