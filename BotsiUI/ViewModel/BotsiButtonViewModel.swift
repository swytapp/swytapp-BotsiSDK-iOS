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
    
    private let model: BotsiButtonModel
    
    init(model: BotsiButtonModel) {
        self.model = model
    }
    
    var text: BotsiButtonModel.ButtonText? {
        model.text
    }
    
    var secondaryText: BotsiButtonModel.ButtonText? {
        model.secondaryText
    }
    
    var font: Font {
        Font.custom(model.text?.font.name ?? "System",
                    size: model.text?.size.toCGFloat() ?? 16)
    }
    
    var textColor: Color {
        model.text?.color?.toColor() ?? .clear
    }
    
    var fillColor: BotsiFillColor? {
        model.style.fillColor
    }
    
    var secondaryFont: Font {
        Font.custom(model.secondaryText?.font.name ?? "System",
                    size: model.secondaryText?.size.toCGFloat() ?? 16)
    }
    
    var secondaryTextColor: Color {
        model.secondaryText?.color?.toColor() ?? .clear
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
    
    var alignment: Alignment {
        switch model.contentLayout?.align {
        case .left: return .leading
        case .right: return .trailing
        default: return .center
        }
    }
    
    var margin: BotsiEdge? {
        model.padding
    }
    
    var padding: BotsiEdge? {
        model.contentLayout?.padding
    }

    func tap() {
        // TODO: - Setup action event
        print("KA: \(model.action)")
    }
}
