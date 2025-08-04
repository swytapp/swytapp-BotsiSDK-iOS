//
//  BotsiNoSwitchCardViewModel.swift
//  Botsi
//
//  Created by Konstantin on 01.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
public final class BotsiNoSwitchCardViewModel: ObservableObject {
    
    private let model: BotsiProductItemModel
    
    var radius: CGFloat {
        model.defaultStyle.radius
    }
    
    var borderThickness: CGFloat {
        model.defaultStyle.borderThickness ?? 0
    }
    
    var borderColor: Color {
        model.defaultStyle.borderColor.toColor()
    }
    
    var text1Size: CGFloat {
        model.defaultState?.text1.size.toCGFloat() ?? 14
    }
    
    var text2Size: CGFloat {
        model.defaultState?.text2.size.toCGFloat() ?? 14
    }
    
    var text3Size: CGFloat {
        model.defaultState?.text3.size.toCGFloat() ?? 14
    }
    
    var text4Size: CGFloat {
        model.defaultState?.text4.size.toCGFloat() ?? 14
    }
    
    var defaultText: BotsiProductItemTextBlock {
        model.defaultText
    }
    
    var text1Color: Color {
        model.defaultState?.text1.color?.toColor() ?? .black
    }
    
    var text2Color: Color {
        model.defaultState?.text2.color?.toColor() ?? .black
    }
    
    var text3Color: Color {
        model.defaultState?.text3.color?.toColor() ?? .black
    }
    
    var text4Color: Color {
        model.defaultState?.text4.color?.toColor() ?? .black
    }
    
    var isBadge: Bool {
        model.isBadge
    }
    
    var badge: BotsiProductItemBadge? {
        model.badge
    }
    
    var backgroundFill: BotsiFillColor {
        model.defaultStyle.fillColor
    }

    public init(model: BotsiProductItemModel) {
        self.model = model
    }
}
