//
//  BotsiTimeViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
final class BotsiTimerViewModel: ObservableObject {
    
    @Published var timeLeft: String = "00:00:00"
    
    private let model: BotsiTimerModel
    
    init(_ model: BotsiTimerModel) {
        self.model = model
        
        Task { await runTimer() }
    }

    private func runTimer() async {
//        while true {
//            let diff = max(0, Int(endDate.timeIntervalSinceNow))
//            await MainActor.run { timeLeft = formatter.string(from: TimeInterval(diff)) ?? "" }
//            try? await Task.sleep(for: .seconds(1))
//        }
    }
}
