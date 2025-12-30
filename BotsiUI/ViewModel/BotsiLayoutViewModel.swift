//
//  BotsiLayoutViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
public final class BotsiLayoutViewModel: ObservableObject {
    
    public let block: BotsiPaywallBlock
    public let model: BotsiLayoutModel

    public var topButtons: [BotsiLayoutModel.TopButton] {
        model.topButtons
    }

    public var fillColor: BotsiFillColor? {
        return model.fillColor
    }

    public var spacing: CGFloat {
        return model.contentLayout.spacing.toCGFloat(default: 0)
    }

    public var padding: BotsiEdge {
        return model.contentLayout.margin
    }

    public init?(_ block: BotsiPaywallBlock) {
        self.block = block
        
        guard case let .layout(model) = block.content else {
            return nil
        }
        
        self.model = model
    }
}
