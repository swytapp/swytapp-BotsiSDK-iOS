//
//  BotsiPurchasesApp_SwiftUI.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import SwiftUI
import Botsi

@available(iOS 16, *)
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
    
    @MainActor
    func activate() async {
        
        // Botsi available methods
    
        do {
            // activate SDK with public key
            try await Botsi.activate("pk_O50YzT5Hv........")
            
            // fetch profile
            let profile = try await Botsi.getProfile()
           
            // fetch paywall with name
            let paywall = try await Botsi.getPaywall(from: "paywall_name")
            
            // fetch products from obtained paywall
            let products = try await Botsi.getPaywallProducts(from: paywall)
            let uiModels = products.compactMap { "\($0.title) \($0.price)..." }
            
            // call this method with getPaywall(from:) to enable analytics for your account
            try await Botsi.logPaywallShown(for: paywall)
            
            // purchase product and fetch updated profile
            let product = products.first
            let profileAfterPurchase = try await Botsi.makePurchase(product)
            
            // restore purchases and fetch updated profile
            let profileAfterRestore = try await Botsi.restorePurchases()
            
        } catch let error as BotsiError {
            print("Botsi Activation Failed: \(error.localizedDescription)")
        } catch {
            print("Unknown error")
        }
    }
}
    
@available(iOS 18, *)
struct BotsiMainView: View {
    @ObservedObject var viewModel: BotsiPurchasesViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Botsi Paywall Main View")
                .backgroundStyle(.black)
                .font(.headline)
        }
    }
}
