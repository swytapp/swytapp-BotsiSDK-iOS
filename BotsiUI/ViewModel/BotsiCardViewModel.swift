//
//  BotsiCardViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 04.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
final class BotsiCardViewModel: ObservableObject {
    
    private let block: BotsiPaywallBlock
    private let model: BotsiCardModel

    init(block: BotsiPaywallBlock, model: BotsiCardModel) {
        self.block = block
        self.model = model
    }

    var children: [BotsiPaywallBlock] {
        block.children?.filter {
            switch $0.content {
            case .text, .image, .button, .list, .timer:
                return true
            default:
                return false
            }
        } ?? []
    }

    var backgroundColor: Color {
        Color(hex: model.style.color).opacity(Double(model.style.opacity) / 100)
    }

    var borderColor: Color {
        Color(hex: model.style.borderColor).opacity(Double(model.style.borderOpacity ?? 0) / 100)
    }

    var borderWidth: CGFloat {
        model.style.borderThickness ?? 0
    }

    var cornerRadius: CGFloat {
        Double(model.style.radius) ?? 0
    }

    var padding: BotsiEdge {
        return model.contentLayout.padding ?? BotsiEdge.defaultEdge
    }
}
