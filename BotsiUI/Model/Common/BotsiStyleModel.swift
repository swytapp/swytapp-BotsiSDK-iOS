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
    public let borderColor: String
    public let borderOpacity: Int?
    public let borderThickness: CGFloat?
    public let radius: CGFloat

    private enum CodingKeys: String, CodingKey {
        case color
        case opacity
        case radius
        case fillColor = "fill_color"
        case borderColor = "border_color"
        case borderOpacity = "border_opacity"
        case borderThickness = "border_thickness"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.fillColor = try container.decodeIfPresent(BotsiFillColor.self, forKey: .fillColor) ?? .solid(.white)
        self.color = try container.decodeIfPresent(String.self, forKey: .color) ?? "#ffffff"
        self.opacity = try container.decodeIfPresent(Int.self, forKey: .opacity) ?? 100
        self.borderColor = try container.decodeIfPresent(String.self, forKey: .borderColor) ?? ""
        self.borderOpacity = try container.decodeIfPresent(Int.self, forKey: .borderOpacity) ?? 100

        if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: .borderThickness) {
            self.borderThickness = CGFloat(doubleValue)
        } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .borderThickness),
                  let doubleValue = Double(stringValue) {
            self.borderThickness = CGFloat(doubleValue)
        } else {
            self.borderThickness = nil
        }

        if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: .radius) {
            self.radius = CGFloat(doubleValue)
        } else if let stringValue = try? container.decodeIfPresent(String.self, forKey: .radius),
                  let doubleValue = Double(stringValue) {
            self.radius = CGFloat(doubleValue)
        } else {
            self.radius = 0
        }
    }
}
