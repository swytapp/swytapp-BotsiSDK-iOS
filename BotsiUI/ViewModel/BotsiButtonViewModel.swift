//
//  BotsiButtonViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
final class BotsiButtonViewModel: ObservableObject {
    
    private(set) var model: BotsiButtonModel
    
    init(model: BotsiButtonModel) {
        self.model = model
    }
    
    var textColor: Color {
        model.text?.textStyle?.color?.toColor() ?? .white
    }
    
    var fillColor: BotsiFillColor? {
        model.style.fillColor
    }
    
    var secondaryTextColor: Color {
        model.secondaryText?.textStyle?.color?.toColor() ?? .white
    }

    var borderColor: Color {
        model.style.borderColor.toColor() ?? .clear
    }
    
    var borderWidth: CGFloat {
        model.style.borderThickness.toCGFloat()
    }
    
    var cornerRadius: CGFloat {
        model.style.radius.toCGFloat() ?? 0
    }
    
    var verticalOffset: CGFloat {
        model.verticalOffset?.toCGFloat() ?? 0
    }
    
    var align: BotsiAlign {
        model.contentLayout?.align ?? .center
    }
}
