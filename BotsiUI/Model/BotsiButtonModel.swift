//
//  BotsiButtonModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiButtonModel: Decodable, Sendable, BotsiPaddingProvider {
    
    public let action: BotsiActionType
    public let actionLabel: String?
    public let purchaseProduct: BotsiPurchaseProduct?
    public let text: ButtonText?
    public let secondaryText: ButtonText?
    public let style: BotsiButtonStyle
    public let padding: BotsiEdge
    public let verticalOffsetString: String?
    public let contentLayout: BotsiContentLayout?

    private enum CodingKeys: String, CodingKey {
        case style, text, action
        case padding = "margin"
        case actionLabel = "action_label"
        case purchaseProduct = "purchase_product"
        case secondaryText = "secondary_text"
        case verticalOffsetString = "vertical_offset"
        case contentLayout = "content_layout"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.action = try container.decode(BotsiActionType.self, forKey: .action)
        self.actionLabel = try container.decodeIfPresent(String.self, forKey: .actionLabel)
        self.purchaseProduct = try container.decodeIfPresent(BotsiPurchaseProduct.self, forKey: .purchaseProduct)
        self.style = try container.decode(BotsiButtonStyle.self, forKey: .style)
        self.text = try container.decodeIfPresent(ButtonText.self, forKey: .text)
        self.secondaryText = try container.decodeIfPresent(ButtonText.self, forKey: .secondaryText)
        self.padding = try container.decodeIfPresent(BotsiEdge.self, forKey: .padding) ?? .defaultEdge
        self.contentLayout = try container.decodeIfPresent(BotsiContentLayout.self, forKey: .contentLayout)
        self.verticalOffsetString = try container.decodeIfPresent(String.self, forKey: .verticalOffsetString)
    }

    public var textColor: Color {
        text?.textStyle?.color?.toColor() ?? .white
    }
    
    public var fillColor: BotsiFillColor? {
        style.fillColor
    }
    
    public var secondaryTextColor: Color {
        secondaryText?.textStyle?.color?.toColor() ?? .white
    }

    public var borderColor: Color {
        style.borderColor.toColor() ?? .clear
    }
 
    public var verticalOffset: CGFloat {
        verticalOffsetString?.toCGFloat() ?? 0
    }
    
    public var align: BotsiAlign {
        contentLayout?.align ?? .center
    }
}

@available(iOS 15.0, *)
public struct ButtonText: Decodable, Sendable {
    public let text: String
    public let textStyle: BotsiTextStyleModel?

    private enum CodingKeys: String, CodingKey {
        case text
        case textStyle = "text_style"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        textStyle = try container.decodeIfPresent(BotsiTextStyleModel.self, forKey: .textStyle)
    }
}
