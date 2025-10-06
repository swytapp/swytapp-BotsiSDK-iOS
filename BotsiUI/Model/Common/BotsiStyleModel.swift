//
//  BotsiStyleModel.swift
//  Botsi
//
//  Created by Konstantin on 12.07.2025.
//

import Foundation

@available(iOS 15.0, *)
public struct BotsiStyleModel: Decodable, Sendable {
    
    public let fillColor: BotsiFillColor
    public let color: String
    public let opacity: Int
    public let borderColor: BotsiFillColor
    public let borderOpacity: Int?
    public let borderWidth: CGFloat
    public let radius: CGFloat

    private enum CodingKeys: String, CodingKey {
        case color
        case opacity
        case radius
        case fillColor = "fill_color"
        case borderColor = "border_color"
        case borderOpacity = "border_opacity"
        case borderWidth = "border_thickness"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.fillColor = try container.decodeIfPresent(BotsiFillColor.self, forKey: .fillColor) ?? .solid(.white)
        self.color = try container.decodeIfPresent(String.self, forKey: .color) ?? "#ffffff"
        self.opacity = try container.decodeIfPresent(Int.self, forKey: .opacity) ?? 100
        self.borderColor = try container.decodeIfPresent(BotsiFillColor.self, forKey: .borderColor) ?? .solid(.clear)
        self.borderOpacity = try container.decodeIfPresent(Int.self, forKey: .borderOpacity) ?? 100
        self.borderWidth = try container.decodeCGFloat(forKey: .borderWidth)
        self.radius = try container.decodeCGFloat(forKey: .radius)
    }
}
