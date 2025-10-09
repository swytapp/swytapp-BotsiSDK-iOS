//
//  BotsiButtonBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiButtonBlockView: View {
    
    @EnvironmentObject var actionHandler: PaywallActionHandler
    private let model: BotsiButtonModel

    init(model: BotsiButtonModel) {
        self.model = model
    }
    
    public var body: some View {
        HStack {
            
            buttonContent
                .padding(model.contentLayout?.padding)
                .styledContainer(
                    fillColor: model.fillColor,
                    borderColor: model.style.borderColor,
                    borderThickness: model.style.borderWidth,
                    cornerRadius: model.style.cornerRadius
                )
        }
        .offset(y: model.verticalOffset)
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        Button {
            actionHandler.handleAction(.action(model.action, customId: model.actionLabel))
        } label: {
            VStack(spacing: 0) {
                if let text = model.text, !text.text.isEmpty {
                    BotsiTextBlockView(propertiesProvider: text.textStyle,
                                       text: text.text,
                                       align: model.align)
                    .frame(maxWidth: .infinity, alignment: model.contentLayout?.align?.alignments.frame ?? .center)
                }
                
                if let secondaryText = model.secondaryText, !secondaryText.text.isEmpty {
                    BotsiTextBlockView(propertiesProvider: secondaryText.textStyle,
                                       text: secondaryText.text,
                                       align: model.align)
                    .frame(maxWidth: .infinity, alignment: model.contentLayout?.align?.alignments.frame ?? .center)
                }
            }
        }
    }
}
