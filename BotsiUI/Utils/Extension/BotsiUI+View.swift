//
//  BotsiUI+View.swift
//  Botsi
//
//  Created by Konstantin on 13.07.2025.
//

import SwiftUI

// MARK: - For conditional modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        ifTransform: (Self) -> TrueContent,
        elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
}
