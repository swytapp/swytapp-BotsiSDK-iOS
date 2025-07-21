//
//  BotsiFooterViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 20.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
public final class BotsiFooterViewModel: ObservableObject, Identifiable {
    
    private let model: BotsiFooterModel
    private let block: BotsiBlockMeta
    public var childrens: [BotsiPaywallBlock] = []
    
    var spacing: CGFloat {
        model.spacing.toCGFloat()
    }
    
    var padding: BotsiEdge {
        model.padding
    }
    
    var fillColor: BotsiFillColor {
        model.style.fillColor
    }
    
    var radius: CGFloat {
        model.style.radius
    }

    public init?(block: BotsiPaywallBlock, model: BotsiFooterModel) {
        guard case let .footer(decodedModel) = block.content else {
            return nil
        }
        
        let blockMeta = block.meta
        let children = block.children ?? []
        
        self.model = decodedModel
        self.block = blockMeta
        self.childrens = children
    }
}
