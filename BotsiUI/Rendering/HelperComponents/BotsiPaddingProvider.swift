//
//  BotsiPaddingProvider.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 18.08.2025.
//

import Foundation

@available(iOS 15.0, *)
public protocol BotsiPaddingProvider {
    var padding: BotsiEdge { get }
}
