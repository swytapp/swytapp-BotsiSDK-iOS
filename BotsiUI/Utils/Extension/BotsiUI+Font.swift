//
//  BotsiUI+Font.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 13.08.2025.
//

import SwiftUI

extension Font.Weight {
    static func fontWeight(from value: Int) -> Font.Weight {
        switch value {
        case 100: return .ultraLight
        case 200: return .thin
        case 300: return .light
        case 400: return .regular
        case 500: return .medium
        case 600: return .semibold
        case 700: return .bold
        case 800: return .heavy
        case 900: return .black
        default: return .regular
        }
    }
}

extension Font {
    static func customFont(ofSize size: CGFloat,
                           name: String,
                           weight: Int,
                           italic: Bool) -> Font {
        let fontWeight = Font.Weight.fontWeight(from: weight)
        var font: Font
        
        if name.contains("System") {
            font = Font.system(size: size)
        } else {
            font = Font.custom(name, size: size)
        }

        return italic ? font.weight(fontWeight).italic() : font.weight(fontWeight)
    }
}
