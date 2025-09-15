//
//  BotsiTimerBlockView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BotsiTimerBlockView: View {
    
    @StateObject private var viewModel: BotsiTimerViewModel
    @EnvironmentObject private var actionHandler: PaywallActionHandler
    @State private var hasTriggeredEndAction = false
    
    init(viewModel: BotsiTimerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        BotsiTextBlockView(propertiesProvider: viewModel.style,
                           text: viewModel.fullText,
                           align: viewModel.style.align ?? .center,
                           maxLines: 1,
                           onOverflow: .scale)
        .offset(y: viewModel.verticalOffset.toCGFloat())
        .onChange(of: viewModel.hasEnded) { hasEnded in

            if hasEnded && !hasTriggeredEndAction && viewModel.triggerCustomAction {
                hasTriggeredEndAction = true
                viewModel.triggerEndTimerAction(actionHandler: actionHandler)
            }
        }
    }
}

