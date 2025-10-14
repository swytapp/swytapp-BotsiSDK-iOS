//
//  BottomSheetContainerView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 09.10.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BottomSheetContainerView: View {
    @EnvironmentObject var actionHandler: PaywallActionHandler
    
    private let model: BotsiProductsModel
    private let bottomSheetModel: BotsiBottomSheetModel
    private let products: [BotsiProductItemModel]

    @State private var isHidden = true
    
    public init(
        model: BotsiProductsModel,
        bottomSheetModel: BotsiBottomSheetModel,
        products: [BotsiProductItemModel]
    ) {
        self.model = model
        self.bottomSheetModel = bottomSheetModel
        self.products = products
    }
    
    public var body: some View {
        ZStack {
            bottomSheetOverlay
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3).delay(0.15)) {
                isHidden = false
            }
        }
    }
}

// MARK: - Bottom Sheet Overlay
@available(iOS 15.0, *)
private extension BottomSheetContainerView {
    var bottomSheetOverlay: some View {
        ZStack {
            if !isHidden {
                blurBackground
            }
            
            VStack {
                Spacer()
                sheetContent
            }
        }
    }
    
    var blurBackground: some View {
            Color.black
            .opacity(0.5)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isHidden = true
                    actionHandler.setBottomSheetPresented(false)
                }
            }
    }
    
    var sheetContent: some View {
        VStack(spacing: 0) {
            sheetHeader
            
            NoToggleProductsContainerView(
                model: model,
                products: products,
                layout: bottomSheetModel.contentLayout,
                padding: bottomSheetModel.padding,
                offset: bottomSheetModel.verticalOffset.toCGFloat()
            )
            
            purchaseButton
                 .padding(bottomSheetModel.purchaseButton.padding)
        }
        .padding(16)
        .styledContainer(
            fillColor: bottomSheetModel.sheetStyle.fillColor,
            borderColor: bottomSheetModel.sheetStyle.borderColor,
            borderThickness: bottomSheetModel.sheetStyle.borderWidth,
            cornerRadius: bottomSheetModel.sheetStyle.radius
        )
    }
}

// MARK: - Sheet Header
@available(iOS 15.0, *)
private extension BottomSheetContainerView {
    var sheetHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                titleIfNeeded()
                secondaryTextIfNeeded()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            closeButton
        }
    }

    @ViewBuilder
    func titleIfNeeded() -> some View {
        if !bottomSheetModel.titleText.isEmpty {
            BotsiTextBlockView(
                propertiesProvider: bottomSheetModel.titleTextStyle,
                text: bottomSheetModel.titleText,
                align: .left,
                maxLines: 1
            )
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func secondaryTextIfNeeded() -> some View {
        if !bottomSheetModel.secondaryText.isEmpty {
            BotsiTextBlockView(
                propertiesProvider: bottomSheetModel.secondaryTextStyle,
                text: bottomSheetModel.secondaryText,
                align: .left,
                maxLines: 1
            )
        } else {
            EmptyView()
        }
    }
    
    var closeButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isHidden = true
                actionHandler.setBottomSheetPresented(false)
            }
        }) {
            Image(systemName: "xmark")
                .resizable()
                .frame(
                    width: bottomSheetModel.iconSize.toCGFloat() / 2,
                    height: bottomSheetModel.iconSize.toCGFloat() / 2
                )
                .padding(8)
                .foregroundColor(bottomSheetModel.iconColor.toColor())
        }
        .styledContainer(
            fillColor: bottomSheetModel.closeButtonStyle.fillColor,
            borderColor: bottomSheetModel.closeButtonStyle.borderColor,
            borderThickness: bottomSheetModel.closeButtonStyle.borderWidth,
            cornerRadius: bottomSheetModel.closeButtonStyle.radius
        )
    }
}

// MARK: - Purchase Button
@available(iOS 15.0, *)
private extension BottomSheetContainerView {
    var purchaseButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isHidden = true
                actionHandler.setBottomSheetPresented(false)
                actionHandler.handleAction(.purchaseSelected)
            }
        }) {
            BotsiTextBlockView(
                propertiesProvider: bottomSheetModel.purchaseButton.textStyle,
                text: bottomSheetModel.purchaseButton.text,
                align: bottomSheetModel.purchaseButton.align
            )
            .frame(maxWidth: .infinity, alignment: bottomSheetModel.purchaseButton.align.alignments.frame)
            .padding(bottomSheetModel.purchaseButton.contentPadding)
        }
        .styledContainer(
            fillColor: bottomSheetModel.purchaseButton.style.fillColor,
            borderColor: bottomSheetModel.purchaseButton.style.borderColor,
            borderThickness: bottomSheetModel.purchaseButton.style.borderWidth,
            cornerRadius: bottomSheetModel.purchaseButton.style.radius
        )
        .offset(y: bottomSheetModel.purchaseButton.verticalOffset.toCGFloat())
    }
}

