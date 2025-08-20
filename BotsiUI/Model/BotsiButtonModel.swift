//
//  BotsiButtonModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiButtonModel: Decodable, Sendable, BotsiPaddingProvider {
    
    public let action: String
    public let actionLabel: String?
    public let text: ButtonText?
    public let secondaryText: ButtonText?
    public let style: BotsiButtonStyle
    public let padding: BotsiEdge
    public let verticalOffset: String?
    public let contentLayout: BotsiContentLayout?

    private enum CodingKeys: String, CodingKey {
        case style, text, action
        case padding = "margin"
        case actionLabel = "action_label"
        case secondaryText = "secondary_text"
        case verticalOffset = "vertical_offset"
        case contentLayout = "content_layout"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.action = try container.decode(String.self, forKey: .action)
        self.actionLabel = try container.decodeIfPresent(String.self, forKey: .actionLabel)
        self.style = try container.decode(BotsiButtonStyle.self, forKey: .style)
        self.text = try container.decodeIfPresent(ButtonText.self, forKey: .text)
        self.secondaryText = try container.decodeIfPresent(ButtonText.self, forKey: .secondaryText)
        self.padding = try container.decodeIfPresent(BotsiEdge.self, forKey: .padding) ?? .defaultEdge
        self.contentLayout = try container.decodeIfPresent(BotsiContentLayout.self, forKey: .contentLayout)
        
        if let string = try? container.decodeIfPresent(String.self, forKey: .verticalOffset) {
            self.verticalOffset = string
        } else if let int = try? container.decodeIfPresent(Int.self, forKey: .verticalOffset) {
            self.verticalOffset = String(int)
        } else if let double = try? container.decodeIfPresent(Double.self, forKey: .verticalOffset) {
            self.verticalOffset = String(double)
        } else {
            self.verticalOffset = nil
        }
    }

    public struct ButtonText: Decodable, Sendable {
        public let text: String
        public let font: BotsiLayoutModel.DefaultFont
        public let size: String
        public let color: BotsiFillColor?
    }
}
