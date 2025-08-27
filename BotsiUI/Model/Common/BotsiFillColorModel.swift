//
//  BotsiFillColorModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 04.07.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public enum BotsiFillColor: Decodable, Sendable {
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
public extension BotsiFillColor {
    func toColor() -> Color {
        switch self {
        case .solid(let color):
            return color
        default:
            return .primary
        }
    }
}

@available(iOS 15.0, *)
extension BotsiFillColor: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        
        if raw.isEmpty {
            self = .solid(.white)
        } else if raw.starts(with: "linear-gradient") {
            guard let gradient = BotsiFillColor.parseGradient(from: raw) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid gradient string")
            }
            self = .gradient(gradient)
        } else {
            guard let color = Color.cssCompatible(raw) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid color string: raw: \(raw)")
            }
            self = .solid(color)
        }
    }
    
    private static func parseGradient(from css: String) -> LinearGradient? {
        guard let (angle, colorStopsString) = extractGradientComponents(from: css) else {
            return nil
        }
        
        guard let stops = parseColorStops(from: colorStopsString), stops.count >= 2 else {
            return nil
        }
        
        let (startPoint, endPoint) = calculateGradientPoints(for: angle)
        return LinearGradient(stops: stops, startPoint: startPoint, endPoint: endPoint)
    }
    
    private static func extractGradientComponents(from css: String) -> (angle: Double, colorStops: String)? {
        let pattern = #"linear-gradient\(([\d.]+)deg,\s*((?:rgba?\([^)]+\)\s*\d+%)(?:\s*,\s*rgba?\([^)]+\)\s*\d+%)*)\)"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        guard
            let match = regex?.firstMatch(in: css, range: NSRange(location: 0, length: css.utf16.count)),
            match.numberOfRanges == 3,
            let angleRange = Range(match.range(at: 1), in: css),
            let colorsRange = Range(match.range(at: 2), in: css)
        else {
            return nil
        }
        
        let angle = Double(css[angleRange]) ?? 0
        let colorStopsString = String(css[colorsRange])
        return (angle, colorStopsString)
    }
    
    private static func parseColorStops(from colorStopsString: String) -> [Gradient.Stop]? {
        let colorStopPattern = #"(rgba?\([^)]+\))\s*(\d+)%"#
        let colorStopRegex = try? NSRegularExpression(pattern: colorStopPattern, options: [])
        let matches = colorStopRegex?.matches(in: colorStopsString, range: NSRange(location: 0, length: colorStopsString.utf16.count)) ?? []
        
        let stops = matches.compactMap { match -> Gradient.Stop? in
            guard match.numberOfRanges == 3,
                  let colorRange = Range(match.range(at: 1), in: colorStopsString),
                  let positionRange = Range(match.range(at: 2), in: colorStopsString),
                  let color = Color.cssCompatible(String(colorStopsString[colorRange])),
                  let position = Double(colorStopsString[positionRange])
            else { return nil }
            
            return Gradient.Stop(color: color, location: position / 100.0)
        }
        
        return stops.sorted { $0.location < $1.location }
    }
    
    private static func calculateGradientPoints(for angle: Double) -> (start: UnitPoint, end: UnitPoint) {
        switch angle {
        case 0...44:
            return (.bottom, .top)
        case 45...89:
            return (.bottomLeading, .topTrailing)
        case 90...134:
            return (.leading, .trailing)
        case 135...179:
            return (.topLeading, .bottomTrailing)
        case 180...224:
            return (.top, .bottom)
        case 225...269:
            return (.topTrailing, .bottomLeading)
        case 270...314:
            return (.trailing, .leading)
        case 315...360:
            return (.bottomTrailing, .topLeading)
        default:
            return (.bottom, .top)
        }
    }
}

@available(iOS 15.0, *)
public extension BotsiFillColor {
    var asAnyView: AnyView {
        switch self {
        case .solid(let color):
            return AnyView(color)
        case .gradient(let gradient):
            return AnyView(gradient)
        }
    }
    
    var asColorOrDefault: Color {
        switch self {
        case .solid(let color):
            return color
        case .gradient:
            return .clear
        }
    }
    
    var isGradient: Bool {
        if case .gradient = self { return true } else { return false }
    }
}
