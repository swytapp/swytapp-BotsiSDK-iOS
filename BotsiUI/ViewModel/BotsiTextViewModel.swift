//
//  BotsiTextViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
final class BotsiTextViewModel: ObservableObject {
    
    private let model: BotsiTextViewModel
    
    init(_ model: BotsiTextViewModel) {
        self.model = model
    }
}
