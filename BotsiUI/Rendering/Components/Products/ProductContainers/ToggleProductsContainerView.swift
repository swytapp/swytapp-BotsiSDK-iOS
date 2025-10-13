//
//  ToggleProductsContainerView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 02.10.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct ToggleProductsContainerView: View {
    @EnvironmentObject private var actionHandler: PaywallActionHandler
    let model: BotsiProductsModel
    
    let toggleOnProducts: [BotsiProductItemModel]
    let toggleOffProducts: [BotsiProductItemModel]
    
    let toggleOnModel: BotsiToggleOnModel
    let toggleOffModel: BotsiToggleOffModel
    
    let toggleModel: BotsiToggleControlModel
    
    @State private var isOn: Bool = false
    
    private var primaryText: String {
        isOn ? toggleModel.activeState.text : toggleModel.inactiveState.text
    }
    
    private var primaryStyle: BotsiTextStyleModel? {
        isOn ? toggleModel.activeState.textStyle : toggleModel.inactiveState.textStyle
    }
    
    private var secondaryText: String {
        isOn ? toggleModel.activeState.secondaryText : toggleModel.inactiveState.secondaryText
    }
    
    private var secondaryStyle: BotsiTextStyleModel {
        isOn ? toggleModel.activeState.secondaryTextStyle : toggleModel.inactiveState.secondaryTextStyle
    }
    
    private var toggleProperties: (contentLayout: BotsiContentLayout, padding: BotsiEdge, offset: CGFloat) {
        if isOn {
            return (toggleOnModel.contentLayout, toggleOnModel.padding, toggleOnModel.verticalOffset.toCGFloat())
        } else {
            return (toggleOffModel.contentLayout, toggleOffModel.padding, toggleOffModel.verticalOffset.toCGFloat())
        }
    }
    
    var body: some View {
        VStack(spacing: model.contentLayout.spacing) {
            HStack(alignment: .center, spacing: 12) {
                Group {
                    VStack(alignment: .leading, spacing: 4) {
                        BotsiTextBlockView(propertiesProvider: primaryStyle,
                                           text: primaryText,
                                           align: .left)
                        BotsiTextBlockView(propertiesProvider: secondaryStyle,
                                           text: secondaryText,
                                           align: .left)
                    }
                    .frame(maxWidth: .infinity)
                    Toggle("", isOn: $isOn)
                        .tint(toggleModel.toggleColor.toColor())
                        .labelsHidden()
                }
                .padding(toggleModel.contentLayout.padding)
            }
            .styledContainer(fillColor: toggleModel.toggleStyle.fillColor,
                             borderColor: toggleModel.toggleStyle.borderColor,
                             borderThickness: toggleModel.toggleStyle.borderWidth,
                             cornerRadius: toggleModel.toggleStyle.radius)
            .padding(toggleModel.padding)
            .offset(y: toggleModel.verticalOffset.toCGFloat())
            
            NoToggleProductsContainerView(model: model,
                                          products: isOn ? toggleOnProducts : toggleOffProducts,
                                          layout: toggleProperties.contentLayout,
                                          padding: toggleProperties.padding,
                                          offset: toggleProperties.offset)
        }
        .padding(model.padding)
        .onAppear {
            isOn = toggleModel.toggleState == .on
        }
        .onChange(of: isOn) { _ in
            updateSelectedProduct()
        }
    }
    
    private func updateSelectedProduct() {
        let selectedId: String?
        if isOn {
            selectedId = toggleOnProducts.first(where: { $0.state == .selected })?.productId
        } else {
            selectedId = toggleOffProducts.first(where: { $0.state == .selected })?.productId
        }
        actionHandler.handleAction(.selectProduct(selectedId ?? ""))
    }
}
