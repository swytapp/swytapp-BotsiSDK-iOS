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
            let pattern = #"rgba?\((\d+), ?(\d+), ?(\d+), ?([\d.]+)\)"#
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            guard
                let match = regex?.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)),
                match.numberOfRanges == 5,
                let r = Int(string[Range(match.range(at: 1), in: string)!]),
                let g = Int(string[Range(match.range(at: 2), in: string)!]),
                let b = Int(string[Range(match.range(at: 3), in: string)!]),
                let a = Double(string[Range(match.range(at: 4), in: string)!])
            else {
                return nil
            }
            return Color(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: a)
        } else if string.hasPrefix("#") {
            return Color(hex: string)
        }
        return nil
    }
}
