//
//  File.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 18.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiUIPaddingModifier: ViewModifier {
    var insets: BotsiEdge?
    
    public func body(content: Content) -> some View {
        if let insets {
            content
                .padding(EdgeInsets(top: insets.top,
                                    leading: insets.left,
                                    bottom: insets.bottom,
                                    trailing: insets.right))
        } else {
            content
        }
    }
}

@available(iOS 15.0, *)
public extension View {
    @ViewBuilder
    func padding(_ insets: BotsiEdge?) -> some View {
        if let insets {
            modifier(BotsiUIPaddingModifier(insets: insets))
        } else {
            self
        }
    }
}
