//
//  BotsiProductStyleHelper.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@MainActor
@available(iOS 15.0, *)
public struct BotsiProductStyleHelper {
    
    let productStyle: BotsiProductsModel
    let product: BotsiProductItemModel

    let alignment: BotsiAlign
    let layout: BotsiContentLayout
    let selectedProductId: String?
    
    init(product: BotsiProductItemModel, productStyle: BotsiProductsModel, layout: BotsiContentLayout? = nil, selectedProductId: String? = nil) {
        self.product = product
        self.productStyle = productStyle
        self.alignment = layout?.align ?? productStyle.contentLayout.align ?? .center
        self.layout = layout ?? productStyle.contentLayout
        self.selectedProductId = selectedProductId ?? productStyle.selectedProduct
    }

    var text: BotsiProductItemTextBlock {
        switch product.offerState {
        case .default:
            return product.defaultText
        case .freeTrial:
            return product.freeText
        case .payAsYouGo:
            return product.paygText
        case .payUpFront:
            return product.paufText
        }
    }
    
    func texts(isSelected: Bool) -> [(index: Int, textStyle: BotsiTextStyleModel, text: String)] {
        let currentTextStyle = textStyle(isSelected: isSelected)
        return [(index: 0, textStyle: currentTextStyle.text1, text: text.text1),
                (index: 1, textStyle: currentTextStyle.text2, text: text.text2),
                (index: 2, textStyle: currentTextStyle.text3, text: text.text3),
                (index: 3, textStyle: currentTextStyle.text4, text: text.text4)]
    }
    
    func textStyle(isSelected: Bool) -> BotsiProductItemTextState {
        isSelected ? product.selectedState : product.defaultState
    }
    
    func style(isSelected: Bool) -> BotsiStyleModel {
        isSelected ? (product.selectedStyle ?? product.defaultStyle) : product.defaultStyle
    }
    
    func textAlignment(for index: Int) -> BotsiAlign {
        if alignment == .column {
            return index < 2 ? .left : .right
        } else {
            return alignment
        }
    }
}
