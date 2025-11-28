//
//  BotsiTextBlockProvider.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 15.08.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public protocol BotsiTextPropertiesProvider {
    var font: BotsiLayoutModel.DefaultFont? { get }
    var size: String? { get }
    var color: BotsiFillColor? { get }
    var selectedColor: BotsiFillColor? { get }
    var customFont: BotsiCustomFont? { get }
}

@available(iOS 15.0, *)
extension BotsiTextPropertiesProvider {
    var textSize: CGFloat {
        CGFloat(Double(size ?? "14") ?? 14)
    }
}
