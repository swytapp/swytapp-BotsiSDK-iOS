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
    private let onHeightChange: ((CGFloat) -> Void)?
    
    public init(model: BotsiFooterHelper, onHeightChange: ((CGFloat) -> Void)? = nil) {
        self.footer = model
        self.onHeightChange = onHeightChange
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
        .padding(.top, 15)
        .background(
            GeometryReader { contentGeometry in
                Color.clear
                    .onAppear {
                        onHeightChange?(contentGeometry.size.height)
                    }
                    .onChange(of: contentGeometry.size.height) { newHeight in
                        onHeightChange?(newHeight)
                    }
            }
        )
        .styledContainer(
            fillColor: footer.model.style.fillColor,
            borderColor: footer.model.style.borderColor,
            borderThickness: footer.model.style.borderThickness ?? 0,
            cornerRadius: footer.radius
        )
    }
}
