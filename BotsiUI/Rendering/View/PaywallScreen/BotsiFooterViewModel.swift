//
//  BotsiFooterViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 20.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
public final class BotsiFooterViewModel: ObservableObject, Identifiable {
    
    public let model: BotsiFooterModel

    public init(_ model: BotsiFooterModel) {
        self.model = model
    }
}
