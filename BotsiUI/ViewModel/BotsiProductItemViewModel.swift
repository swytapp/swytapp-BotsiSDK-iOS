//
//  BotsiProductItemViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
final class BotsiProductItemViewModel: ObservableObject {
    
    private let model: BotsiProductItemModel

    init(_ model: BotsiProductItemModel) {
        
        self.model = model
    }
}
