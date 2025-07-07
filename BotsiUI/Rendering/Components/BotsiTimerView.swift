//
//  BotsiTimerView.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct BotsiTimerBlockView: View {
    
    @StateObject private var vm: BotsiTimerViewModel
    
    init(viewModel: BotsiTimerViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Text(vm.timeLeft).monospacedDigit()
    }
}
