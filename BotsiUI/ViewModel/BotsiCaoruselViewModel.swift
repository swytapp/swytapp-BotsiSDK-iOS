//
//  BotsiCaoruselViewModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 18.06.2025.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
final class BotsiCarouselViewModel: ObservableObject {
    
    @Published var index: Int = 0
    
    
    private let model: BotsiCarouselModel
    private var timerTask: Task<Void, Never>?

    init(_ model: BotsiCarouselModel) {
        self.model = model
    }
    
    deinit {
//        timerTask?.cancel()
    }

    private func startTimer(interval: TimeInterval) {
//        timerTask = Task {
//            while true {
//                try? await Task.sleep(for: .seconds(interval))
//                await MainActor.run { index = (index + 1) % children.count }
//            }
//        }
    }
}
