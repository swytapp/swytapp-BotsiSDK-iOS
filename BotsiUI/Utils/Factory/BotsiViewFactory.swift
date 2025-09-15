//
//  BotsiViewFactory.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@MainActor
@available(iOS 15.0, *)
public enum BotsiViewFactory {
    
    static func makeTimer(
        model: BotsiTimerModel,
        timerProvider: BotsiTimerProvider? = nil
    ) -> BotsiTimerBlockView {
        let viewModel = BotsiTimerViewModel(model: model, timerProvider: timerProvider)
        return BotsiTimerBlockView(viewModel: viewModel)
    }
    
    static func makeButton(model: BotsiButtonModel) -> BotsiButtonBlockView {
        let viewModel = BotsiButtonViewModel(model: model)
        return BotsiButtonBlockView(viewModel: viewModel)
    }
}
