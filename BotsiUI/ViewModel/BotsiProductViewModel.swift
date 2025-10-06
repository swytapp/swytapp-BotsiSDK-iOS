//
//  BotsiProductViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@MainActor
@available(iOS 15.0, *)
final class BotsiProductViewModel: ObservableObject {
    
    public let product: BotsiProductItemModel
    private let productStyle: BotsiProductsModel

    let alignment: BotsiAlign
    let layout: BotsiContentLayout
    let selectedProductId: String?
    
    func texts(actionHandler: PaywallActionHandler) -> [(Int, BotsiTextStyleModel, String)] {
        let currentTextStyle = textStyle(actionHandler: actionHandler)
        return [(0, currentTextStyle.text1, text.text1),
                (1, currentTextStyle.text2, text.text2),
                (2, currentTextStyle.text3, text.text3),
                (3, currentTextStyle.text4, text.text4)]
    }
    
    func isSelected(actionHandler: PaywallActionHandler) -> Bool {
        guard let selectedProductId = actionHandler.selectedProductId else {
            return product.state == .selected
        }
        return selectedProductId == product.productId
    }
    
    func textStyle(actionHandler: PaywallActionHandler) -> BotsiProductItemTextState {
        isSelected(actionHandler: actionHandler) ? product.selectedState : product.defaultState
    }
    
    func style(actionHandler: PaywallActionHandler) -> BotsiStyleModel {
        isSelected(actionHandler: actionHandler) ? product.selectedStyle : product.defaultStyle
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
    
    init(product: BotsiProductItemModel, productStyle: BotsiProductsModel, layout: BotsiContentLayout? = nil, selectedProductId: String? = nil) {
        self.product = product
        self.productStyle = productStyle
        self.alignment = layout?.align ?? productStyle.contentLayout.align ?? .center
        self.layout = layout ?? productStyle.contentLayout
        self.selectedProductId = selectedProductId ?? productStyle.selectedProduct
    }
    
    func textAlignment(for index: Int) -> BotsiAlign {
        if alignment == .column {
            return index < 2 ? .left : .right
        } else {
            return alignment
        }
    }
}

