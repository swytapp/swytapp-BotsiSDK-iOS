//
//  BotsiTextBlockProvider.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 15.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public protocol BotsiTextBlockProvider {
    var font: BotsiLayoutModel.DefaultFont { get }
    var size: String { get }
    var color: BotsiFillColor { get }
}

@available(iOS 15.0, *)
extension BotsiTextBlockProvider {
    var textSize: CGFloat {
        CGFloat(Double(size) ?? 14)
    }
}
