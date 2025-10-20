//
//  BotsiProductView.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 16.09.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiProductView: View {
    private var styleHelper: BotsiProductStyleHelper
    @EnvironmentObject private var actionHandler: PaywallActionHandler
    @EnvironmentObject private var productViewModel: BotsiProductViewModel
    
    init(styleHelper: BotsiProductStyleHelper) {
        self.styleHelper = styleHelper
    }
    
    public var body: some View {
        Group {
            if styleHelper.alignment == .column {
                columnLayout
            } else {
                rowLayout
            }
        }
        .padding(styleHelper.layout.padding)
        .styledContainer(fillColor: styleHelper.style(isSelected: isSelected).fillColor,
                         borderColor: styleHelper.style(isSelected: isSelected).borderColor,
                         borderThickness: styleHelper.style(isSelected: isSelected).borderWidth,
                         cornerRadius: styleHelper.style(isSelected: isSelected).radius)
        .overlay(alignment: .top) {
            if styleHelper.product.isBadge {
                badgeView
            }
        }
        .onTapGesture {
            guard let productId = Int(styleHelper.product.productId ?? "") else {
                return
            }
            productViewModel.selectProduct(productId: productId)
        }
    }

    private var isSelected: Bool {
        guard let selectedProductId = productViewModel.selectedProductId else {
            return styleHelper.product.state == .selected
        }
        return String(selectedProductId) == styleHelper.product.productId
    }
}

@available(iOS 15.0, *)
private extension BotsiProductView {
    
    var badgeView: some View {
        let badge = styleHelper.product.badge
        return BotsiTextBlockView(
            propertiesProvider: badge,
            text: badge.badgeText,
            align: .center,
        )
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .fixedSize()
        .background(
            RoundedRectangle(cornerRadius: badge.badgeRadius.toCGFloat())
                .fill(badge.badgeColor.toColor())
        )
        .offset(y: (badge.size?.toCGFloat() ?? 0) * -0.7)
    }
    
    var columnLayout: some View {
        HStack {
            VStack(spacing: 6) {
                textViewGroup(styleHelper.texts(isSelected: isSelected).filter { $0.index == 0 || $0.index == 1 })
            }
            VStack(spacing: 6) {
                textViewGroup(styleHelper.texts(isSelected: isSelected).filter { $0.index == 2 || $0.index == 3 })
            }
        }
    }
    
    var rowLayout: some View {
        VStack(spacing: 6) {
            ForEach(styleHelper.texts(isSelected: isSelected), id: \.index) { index, textStyle, text in
                if !text.isEmpty {
                    BotsiTextBlockView(propertiesProvider: textStyle,
                                       text: text,
                                       align: styleHelper.textAlignment(for: index),
                                       height: .infinity)
                    .frame(maxHeight: .infinity)
                }
            }
        }
    }
    
    @ViewBuilder
    func textViewGroup(_ texts: [(Int, BotsiTextStyleModel, String)]) -> some View {
        ForEach(texts, id: \.0) { index, textStyle, text in
            BotsiTextBlockView(propertiesProvider: textStyle,
                               text: text,
                               align: styleHelper.textAlignment(for: index),
                               height: .infinity)
            .frame(maxHeight: .infinity)
        }
    }
}
