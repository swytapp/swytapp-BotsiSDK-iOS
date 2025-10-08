//
//  TabProductsContainerView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 06.10.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct TabProductsContainerView: View {
    let model: BotsiProductsModel
    let tabControlModel: BotsiTabControlModel
    let tabModels: [(id: String, tabModel: BotsiTabModel, products: [BotsiProductItemModel])]
    
    @State private var selectedTabId: String

    public init(model: BotsiProductsModel, tabControlModel: BotsiTabControlModel, tabModels: [(String, BotsiTabModel, [BotsiProductItemModel])]) {
        self.model = model
        self.tabControlModel = tabControlModel
        self.tabModels = tabModels
        self._selectedTabId = State(initialValue: tabControlModel.selectedTab)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            tabControlView
            
            if let selectedTab = tabModels.first(where: { $0.id == selectedTabId }) {
                NoToggleProductsContainerView(
                    model: model,
                    products: selectedTab.products,
                    layout: selectedTab.tabModel.contentLayout,
                    padding: selectedTab.tabModel.padding,
                    offset: selectedTab.tabModel.verticalOffset.toCGFloat(),
                    tabId: selectedTab.id
                )
            }
        }
    }
}

@available(iOS 15.0, *)
private extension TabProductsContainerView {
    
    var tabControlView: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabModels.enumerated()), id: \.offset) { _, tabData in
                let (id, tabModel, _) = tabData
                tabButton(id: id, tabModel: tabModel)
            }
        }
        .frame(maxWidth: .infinity)
        .styledContainer(fillColor: tabControlModel.containerStyle.fillColor,
                         borderColor: tabControlModel.containerStyle.borderColor,
                         borderThickness: tabControlModel.containerStyle.borderWidth,
                         cornerRadius: tabControlModel.containerStyle.radius)
    }

    @ViewBuilder
    func tabButton(id: String, tabModel: BotsiTabModel) -> some View {
        let isSelected = selectedTabId == id
        let tabStyle = isSelected ? tabControlModel.activeTabStyle : tabControlModel.inactiveTabStyle
        
        Button(action: {
            selectedTabId = id
        }) {
            Text(tabModel.title)
                .frame(maxWidth: .infinity)
                .foregroundColor(tabStyle.fontColor.toColor())
                .font(.customFont(
                    ofSize: tabControlModel.textSize.toCGFloat(),
                    name: tabControlModel.tabFont.name,
                    weight: tabControlModel.tabFont.fontWeight,
                    italic: tabControlModel.tabFont.isItalic
                ))
                .padding(tabStyle.padding)
        }
        .styledContainer(fillColor: tabStyle.style.fillColor,
                         borderColor: tabStyle.style.borderColor,
                         borderThickness: tabStyle.style.borderWidth,
                         cornerRadius: tabStyle.style.radius)
        .padding(tabControlModel.padding)
    }
}
