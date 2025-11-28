//
//  BotsiUI+Color.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 19.06.2025.
//

import SwiftUI

extension Color {
    /// Initializes a SwiftUI Color from a hex string like "#RRGGBB" or "#AARRGGBB".
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64

        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // AARRGGBB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // fallback to black on error
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

extension Color {
    static func cssCompatible(_ string: String) -> Color? {
        if string.hasPrefix("rgba") {
            return parseRGBA(string)
        } else if string.hasPrefix("rgb") {
            return parseRGB(string)
        } else if string.hasPrefix("#") {
            return Color(hex: string)
        }
        return nil
    }
    
    private static func parseRGBA(_ string: String) -> Color? {
        let pattern = #"rgba\(([\d.]+), ?([\d.]+), ?([\d.]+), ?([\d.]+)\)"#
        guard let components = extractColorComponents(from: string, pattern: pattern, count: 4) else {
            return nil
        }
        return Color(red: components[0]/255, green: components[1]/255, blue: components[2]/255, opacity: components[3])
    }
    
    private static func parseRGB(_ string: String) -> Color? {
        let pattern = #"rgb\(([\d.]+) ?,?([\d.]+) ?,?([\d.]+)\)"#
        guard let components = extractColorComponents(from: string, pattern: pattern, count: 3) else {
            return nil
        }
        return Color(red: components[0]/255, green: components[1]/255, blue: components[2]/255, opacity: 1.0)
    }
    
    private static func extractColorComponents(from string: String, pattern: String, count: Int) -> [Double]? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        guard
            let match = regex?.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)),
            match.numberOfRanges == count + 1
        else {
            return nil
        }
        
        var components: [Double] = []
        for i in 1...count {
            guard let range = Range(match.range(at: i), in: string),
                  let value = Double(string[range]) else {
                return nil
            }
            components.append(value)
        }
        
        return components
    }
}
