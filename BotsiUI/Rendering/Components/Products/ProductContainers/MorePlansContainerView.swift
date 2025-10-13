//
//  MorePlansContainerView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 08.10.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct MorePlansContainerView: View {
    @EnvironmentObject var actionHandler: PaywallActionHandler
    
    private let model: BotsiProductsModel
    private let basePlans: BotsiPlansModel
    private let morePlans: BotsiPlansModel?
    private let buttonModel: BotsiMoreButtonModel
    private let baseProducts: [BotsiProductItemModel]
    private let moreProducts: [BotsiProductItemModel]
    
    @State private var localMorePlansShown: Bool
    
    private var morePlansShown: Bool {
        model.grouping == .bottomSheet ? actionHandler.isBottomSheetPresented : localMorePlansShown
    }
    
    private var buttonText: MoreButtonText {
        morePlansShown ? buttonModel.moreText : buttonModel.defaultText
    }
    
    public init(
        model: BotsiProductsModel,
        basePlans: BotsiPlansModel,
        morePlans: BotsiPlansModel? = nil,
        buttonModel: BotsiMoreButtonModel,
        baseProducts: [BotsiProductItemModel],
        moreProducts: [BotsiProductItemModel]
    ) {
        self.model = model
        self.basePlans = basePlans
        self.morePlans = morePlans
        self.buttonModel = buttonModel
        self.baseProducts = baseProducts
        self.moreProducts = moreProducts
        self._localMorePlansShown = State(initialValue: buttonModel.state == .morePlansShown)
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
            
            revealButton
            
            if morePlansShown, model.grouping == .revealMore, let morePlans = morePlans {
                NoToggleProductsContainerView(
                    model: model,
                    products: moreProducts,
                    layout: morePlans.contentLayout,
                    padding: morePlans.padding,
                    offset: morePlans.verticalOffset.toCGFloat()
                )
            }
        }
        .padding(model.padding)
    }
}

// MARK: - Reveal button
@available(iOS 15.0, *)
private extension MorePlansContainerView {
    var revealButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                if model.grouping == .bottomSheet {
                    actionHandler.handleAction(.bottomSheet(show: true))
                } else {
                    localMorePlansShown.toggle()
                }
            }
        }) {
            VStack(spacing: 0) {
                titleIfNeeded()
                secondaryTextIfNeeded()
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
        .offset(y: buttonModel.verticalOffset?.toCGFloat() ?? 0)
    }
    
    @ViewBuilder
    func titleIfNeeded() -> some View {
        if !buttonText.text.isEmpty {
            BotsiTextBlockView(propertiesProvider: buttonText.textStyle,
                               text: buttonText.text,
                               align: buttonModel.contentLayout?.align ?? .center)
            .frame(maxWidth: .infinity, alignment: buttonModel.contentLayout?.align?.alignments.frame ?? .center)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    func secondaryTextIfNeeded() -> some View {
        if !buttonText.secondaryText.isEmpty {
            BotsiTextBlockView(propertiesProvider: buttonText.secondaryTextStyle,
                               text: buttonText.secondaryText,
                               align: buttonModel.contentLayout?.align ?? .center)
            .frame(maxWidth: .infinity, alignment: buttonModel.contentLayout?.align?.alignments.frame ?? .center)
        } else {
            EmptyView()
        }
    }
}
