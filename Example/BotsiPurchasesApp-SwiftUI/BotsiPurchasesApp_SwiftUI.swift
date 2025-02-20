//
//  BotsiPurchasesApp_SwiftUI.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import SwiftUI
import Botsi

@main
struct BotsiPurchasesApp_SwiftUI: App {
    private let viewModel: BotsiPurchasesViewModel
    
    init() {
        self.viewModel = BotsiPurchasesViewModel()
    }
    
    var body: some Scene {
        WindowGroup {
            BotsiMainView()
                .environmentObject(viewModel)
                .task {
                    await viewModel.activate()
                }
        }
    }
}

class BotsiPurchasesViewModel: ObservableObject {
    private let botsiConfiguration: BotsiConfiguration
    
    init() {
        let botsiConfiguration = BotsiConfiguration.build(with: "api_key", enableObserver: true)
        self.botsiConfiguration = botsiConfiguration
    }
    
    func activate() {
        Botsi.activate(with: botsiConfiguration)
    }
}
    
    
struct BotsiMainView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Botsi Main View")
                .backgroundStyle(.black)
                .font(.headline)
        }
    }
}
