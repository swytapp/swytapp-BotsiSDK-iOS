//
//  BotsiFooterBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiFooterBlockView: View {
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    private var footer: BotsiFooterHelper
    private let additionalPadding: BotsiEdge = .init(left: 8, top: 0, right: 8, bottom: 0)
    private let onHeightChange: ((CGFloat) -> Void)?
    @EnvironmentObject var actionHandler: PaywallActionHandler
    
    public init(model: BotsiFooterHelper, onHeightChange: ((CGFloat) -> Void)? = nil) {
        self.footer = model
        self.onHeightChange = onHeightChange
    }
    
    public var body: some View {
        VStack(spacing: footer.spacing) {
            ForEach(footer.childrens, id: \.meta.id) { child in
                BotsiBlockRendererView(block: child)
                    .padding(additionalPadding)
                    .padding(footer.padding)
            }
        }
        .padding(.top, 15)
        .padding(.bottom, safeAreaInsets.bottom)
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
            borderThickness: footer.model.style.borderWidth ?? 0,
            cornerRadius: footer.radius,
        )
        .drawingGroup()
    }
}
