//
//  BotsiFillColorModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 04.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public enum BotsiFillColor: Sendable, Decodable {
    case solid(Color)
    case gradient(LinearGradient)
    
    private var identifier: String {
        switch self {
        case .solid(let color):
            return String(describing: color)
        case .gradient(let gradient):
            return String(describing: gradient)
        }
    }
}

@available(iOS 15.0, *)
extension BotsiFillColor: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)

        if raw.starts(with: "linear-gradient") {
            guard let gradient = BotsiFillColor.parseGradient(from: raw) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid gradient string")
            }
            self = .gradient(gradient)
        } else {
            guard let color = Color.cssCompatible(raw) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid color string")
            }
            self = .solid(color)
        }
    }

    private static func parseGradient(from css: String) -> LinearGradient? {
        let pattern = #"linear-gradient\(([\d.]+)deg, (.+)\)"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        guard
            let match = regex?.firstMatch(in: css, range: NSRange(location: 0, length: css.utf16.count)),
            match.numberOfRanges == 3,
            let angleRange = Range(match.range(at: 1), in: css),
            let colorsRange = Range(match.range(at: 2), in: css)
        else {
            return nil
        }

        let _ = Double(css[angleRange])
        let colorStopsString = css[colorsRange]
        let stops = colorStopsString
            .split(separator: ",")
            .compactMap { stop -> Color? in
                let parts = stop.split(separator: " ").map { $0.trimmingCharacters(in: .whitespaces) }
                if let rgbPart = parts.first {
                    return Color.cssCompatible(String(rgbPart))
                }
                return nil
            }

        guard stops.count >= 2 else { return nil }
        return LinearGradient(colors: stops, startPoint: .leading, endPoint: .trailing)
    }
}
