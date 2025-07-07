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
        Color(hex: model.text?.color ?? "#FFFFFF")
            .opacity(Double(model.text?.opacity ?? 100) / 100.0)
    }
    
    var fillColor: Color {
        Color(hex: model.style.color)
            .opacity(Double(model.style.opacity) / 100.0)
    }
    
    var borderColor: Color {
        Color(hex: model.style.borderColor)
            .opacity(Double(model.style.borderOpacity) / 100.0)
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
        model.margin
    }
    
    var padding: BotsiEdge? {
        model.contentLayout?.padding
    }

    func tap() {
        // TODO: - Setup action event
        print("KA: \(model.action)")
    }
}
