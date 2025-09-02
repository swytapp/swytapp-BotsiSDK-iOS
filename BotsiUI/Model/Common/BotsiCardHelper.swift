//
//  BotsiCardHelper.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 04.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiCardHelper {
    
    private let block: BotsiPaywallBlock
    private let model: BotsiCardModel

    public init(block: BotsiPaywallBlock, model: BotsiCardModel) {
        self.block = block
        self.model = model
    }

    public var children: [BotsiPaywallBlock] {
        block.children?.filter {
            switch $0.content {
            case .text, .image, .button, .list, .timer:
                return true
            default:
                return false
            }
        } ?? []
    }

    public var backgroundImage: String? {
        model.backgroundImage
    }

    public var fillColor: BotsiFillColor {
        model.style.fillColor
    }

    public var borderColor: BotsiFillColor {
        model.style.borderColor
    }

    public var borderWidth: CGFloat {
        model.style.borderThickness ?? 0
    }

    public var cornerRadius: CGFloat {
        model.style.radius
    }

    public var padding: BotsiEdge {
        model.contentLayout.padding ?? BotsiEdge.defaultEdge
    }

    public var spacing: CGFloat {
        model.contentLayout.spacing?.toCGFloat() ?? 0
    }

    public var verticalOffset: CGFloat {
        model.verticalOffset?.toCGFloat() ?? 0
    }

    public var hasBackgroundImage: Bool {
        backgroundImage != nil && backgroundImage != ""
    }
}
