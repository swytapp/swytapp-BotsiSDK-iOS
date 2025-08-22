//
//  BotsiFooterBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiFooterBlockView: View {
    
    private var footer: BotsiFooterHelper
    private let additionalPadding: BotsiEdge = .init(left: 8, top: 0, right: 8, bottom: 0)
    
    public init(model: BotsiFooterHelper) {
        self.footer = model
    }
    
    public var body: some View {
        VStack(spacing: footer.spacing) {
            ForEach(footer.childrens, id: \.meta.id) { child in
                BotsiBlockRendererView(block: child) { action in
                    print("KA: \(action)")
                }
                .padding(additionalPadding)
                .padding(footer.padding)
            }
        }
        .padding(.top, 20)
        .background(
            RoundedRectangle(cornerRadius: footer.radius)
                .stroke(footer.model.style.borderColor.toColor(),
                        lineWidth: footer.model.style.borderThickness ?? 0)
                .background(
                    RoundedRectangle(cornerRadius: footer.radius)
                        .fill(Color.clear)
                )
                .ignoresSafeArea()
        )
    }
}
