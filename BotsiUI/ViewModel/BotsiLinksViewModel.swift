//
//  BotsiLinksViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
final class BotsiLinksViewModel: ObservableObject {
    
    private let model: BotsiLinksModel

    init(_ model: BotsiLinksModel) {
        self.model = model
    }
}
