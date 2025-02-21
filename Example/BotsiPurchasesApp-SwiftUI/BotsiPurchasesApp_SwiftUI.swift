//
//  BotsiPurchasesApp_SwiftUI.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import SwiftUI
import Botsi

@available(iOS 18, *)
@main
struct BotsiPurchasesApp_SwiftUI: App {
    private let viewModel: BotsiPurchasesViewModel
    
    init() {
        self.viewModel = BotsiPurchasesViewModel()
    }
    
    var body: some Scene {
        WindowGroup {
            BotsiMainView(viewModel: viewModel)
                .task {
                    await viewModel.activate()
                }
        }
    }
}

@available(iOS 18, *)
class BotsiPurchasesViewModel: ObservableObject {
    private let botsiConfiguration: BotsiConfiguration
    
    init() {
        let botsiConfiguration = BotsiConfiguration.build(
            with: "api_key",
            enableObserver: true
        )
        self.botsiConfiguration = botsiConfiguration
    }
    
    @MainActor
    func activate() async {
        do {
            try await Botsi.activate(with: botsiConfiguration)
        } catch {
            print("Botsi Activation Failed: \(error)")
        }
    }
    
    @MainActor
    func createProfile() async {
        do {
            try await Botsi.createProfile()
        } catch {
            print("Failed to create profile: \(error)")
        }
    }
}
    
@available(iOS 18, *)
struct BotsiMainView: View {
    @ObservedObject var viewModel: BotsiPurchasesViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Botsi Main View")
                .backgroundStyle(.black)
                .font(.headline)
            Button {
                Task {
                    await viewModel.createProfile()
                }
            } label: {
                Text("Create profile")
            }
        }
    }
}
