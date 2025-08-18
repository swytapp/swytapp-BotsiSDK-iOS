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
    var textSize: CGFloat { get }
    var color: BotsiFillColor { get }
}
