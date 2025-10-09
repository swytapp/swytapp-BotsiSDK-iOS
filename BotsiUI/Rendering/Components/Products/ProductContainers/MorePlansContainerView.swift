//
//  MorePlansContainerView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 08.10.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct MorePlansContainerView: View {
    private let model: BotsiProductsModel
    private let basePlans: BotsiMorePlansModel
    private let morePlans: BotsiMorePlansModel
    private let buttonModel: BotsiMoreButtonModel
    private let baseProducts: [BotsiProductItemModel]
    private let moreProducts: [BotsiProductItemModel]
    
    @State private var morePlansShown: Bool
    
    private var buttonText: MoreButtonText {
        morePlansShown ? buttonModel.moreText : buttonModel.defaultText
    }
    
    public init(model: BotsiProductsModel, basePlans: BotsiMorePlansModel, morePlans: BotsiMorePlansModel, buttonModel: BotsiMoreButtonModel, baseProducts: [BotsiProductItemModel], moreProducts: [BotsiProductItemModel]) {
        self.model = model
        self.basePlans = basePlans
        self.morePlans = morePlans
        self.buttonModel = buttonModel
        self.baseProducts = baseProducts
        self.moreProducts = moreProducts
        self._morePlansShown = State(initialValue: buttonModel.state == .morePlansShown)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            NoToggleProductsContainerView(
                model: model,
                products: baseProducts,
                layout: basePlans.contentLayout,
                padding: basePlans.padding,
                offset: basePlans.verticalOffset.toCGFloat()
            )
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    morePlansShown.toggle()
                }
            }) {
                VStack(spacing: 0) {
                    if !buttonText.text.isEmpty {
                        BotsiTextBlockView(propertiesProvider: buttonText.textStyle,
                                           text: buttonText.text,
                                           align: buttonModel.contentLayout?.align ?? .center)
                        .frame(maxWidth: .infinity, alignment: buttonModel.contentLayout?.align?.alignments.frame ?? .center)
                    }
                    
                    if !buttonText.secondaryText.isEmpty {
                        BotsiTextBlockView(propertiesProvider: buttonText.secondaryTextStyle,
                                           text: buttonText.secondaryText,
                                           align: buttonModel.contentLayout?.align ?? .center)
                        .frame(maxWidth: .infinity, alignment: buttonModel.contentLayout?.align?.alignments.frame ?? .center)
                    }
                }
            }
            .padding(buttonModel.contentLayout?.padding)
            .styledContainer(
                fillColor: buttonModel.style.fillColor,
                borderColor: buttonModel.style.borderColor,
                borderThickness: buttonModel.style.borderWidth,
                cornerRadius: buttonModel.style.cornerRadius
            )
            .padding(buttonModel.padding)
            
            if morePlansShown {
                NoToggleProductsContainerView(
                    model: model,
                    products: moreProducts,
                    layout: morePlans.contentLayout,
                    padding: morePlans.padding,
                    offset: morePlans.verticalOffset.toCGFloat()
                )
            }
        }
    }
}
