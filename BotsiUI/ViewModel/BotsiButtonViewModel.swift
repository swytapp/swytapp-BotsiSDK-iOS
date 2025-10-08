//
//  BotsiButtonViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
final class BotsiButtonViewModel: ObservableObject {
    
    private(set) var model: BotsiButtonModel
    
    init(model: BotsiButtonModel) {
        self.model = model
    }
    
    
}
