//
//  BotsiTextStyleModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 21.06.2025.
//
import Foundation

@available(iOS 15.0, *)
public struct BotsiTextStyleModel: Decodable, Sendable, BotsiTextPropertiesProvider {
    public let font: BotsiLayoutModel.DefaultFont?
    public let customFont: BotsiCustomFont?
    public let size: String?
    public let align: BotsiAlign?
    public let color: BotsiFillColor?
    public let opacity: Int?
    public let text: String?

    private enum CodingKeys: String, CodingKey {
        case font
        case size
        case align
        case color
        case opacity
        case text
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        size = try container.decode(String.self, forKey: .size)
        align = try container.decodeIfPresent(BotsiAlign.self, forKey: .align)
        color = try container.decodeIfPresent(BotsiFillColor.self, forKey: .color) ?? .solid(.white)
        opacity = try container.decodeIfPresent(Int.self, forKey: .opacity)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        
        if let defaultFont = try? container.decode(BotsiLayoutModel.DefaultFont.self, forKey: .font) {
            self.font = defaultFont
            self.customFont = nil
        } else if let customFont = try? container.decode(BotsiCustomFont.self, forKey: .font) {
            self.font = nil
            self.customFont = customFont
        } else {
            self.font = nil
            self.customFont = nil
        }
    }
}
