# Botsi + RevenueCat Integration Guide

A streamlined guide for integrating Botsi paywalls with RevenueCat purchase handling.

## Table of Contents
- [Quick Setup](#quick-setup)
- [Purchase Delegate](#purchase-delegate)
- [SwiftUI Integration](#swiftui-integration)
- [UIKit Integration](#uikit-integration)
- [Error Handling](#error-handling)

---

## Quick Setup

### 1. Install Dependencies

**Swift Package Manager:**
```swift
// Add to Package.swift
dependencies: [
    .package(url: "https://github.com/BotsiTeam/BotsiSDK-iOS.git", from: "1.0.10"),
    .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.0.0")
]
```

### 2. Import Frameworks

```swift
import Botsi
import RevenueCat
```

### 3. Initialize SDKs

```swift
// Configure RevenueCat
Purchases.configure(
    with: Configuration.Builder(withAPIKey: "rc_api_key")
        .with(usesStoreKit2IfAvailable: true)
        .build()
)

// Initialize Botsi
try await Botsi.activate("botsi_api_key")
```

---

## Purchase Delegate

Create a custom delegate to handle purchases through RevenueCat:

```swift
struct RevenueCatPurchaseDelegate: BotsiPurchaseDelegate {
    
    // MARK: - Required Methods
    
    func handlePurchase(_ product: BotsiProduct) async -> BotsiPurchaseResult {
        do {
            let offerings = try await Purchases.shared.offerings()
            
            guard let package = findPackage(productId: product.productId, in: offerings) else {
                return .failure(PurchaseError.productNotFound)
            }
            
            let (_, customerInfo, cancelled) = try await Purchases.shared.purchase(package: package)
            
            if cancelled { return .cancelled }
            
            guard customerInfo.entitlements.active.count > 0 else {
                return .failure(PurchaseError.verificationFailed)
            }
            
            // Sync with Botsi
            try await Task.sleep(nanoseconds: 1_000_000_000)
            let profile = try await Botsi.getProfile()
            
            return .success(profile)
            
        } catch let error as ErrorCode where error == .purchaseCancelledError {
            return .cancelled
        } catch {
            return .failure(error)
        }
    }
    
    func handleRestore() async -> BotsiRestoreResult {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            
            guard customerInfo.entitlements.active.count > 0 else {
                return .failure(PurchaseError.noPurchases)
            }
            
            // Sync with Botsi
            try await Task.sleep(nanoseconds: 1_000_000_000)
            let profile = try await Botsi.getProfile()
            
            return .success(profile)
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func findPackage(productId: String, in offerings: Offerings) -> Package? {
        if let current = offerings.current,
           let package = current.availablePackages.first(where: { 
               $0.storeProduct.productIdentifier == productId 
           }) {
            return package
        }
        
        for (_, offering) in offerings.all {
            if let package = offering.availablePackages.first(where: { 
                $0.storeProduct.productIdentifier == productId 
            }) {
                return package
            }
        }
        
        return nil
    }
}

// MARK: - Custom Errors

enum PurchaseError: LocalizedError {
    case productNotFound
    case verificationFailed
    case noPurchases
    
    var errorDescription: String? {
        switch self {
        case .productNotFound: return "Product not found in RevenueCat"
        case .verificationFailed: return "Purchase verification failed"
        case .noPurchases: return "No purchases to restore"
        }
    }
}
```

---

## SwiftUI Integration

### Basic Implementation

```swift
struct PaywallView: View {
    @State private var showPaywall = false
    @State private var paywall: BotsiPaywall?
    @State private var builder: Data?
    
    private let purchaseDelegate = RevenueCatPurchaseDelegate()
    
    var body: some View {
        Button("Show Paywall") {
            Task { await loadPaywall() }
        }
        .botsiPaywall(
            isPresented: $showPaywall,
            paywall: paywall,
            builder: builder,
            purchaseDelegate: purchaseDelegate,
            onAction: handleAction,
            onUIError: handleError
        )
    }
    
    private func loadPaywall() async {
        do {
            paywall = try await Botsi.getPaywall(from: "placement_id")
            builder = try await Botsi.getPaywallBuilder(from: paywall!)
            try await Botsi.logPaywallShown(for: paywall!)
            showPaywall = true
        } catch {
            print("Error: \(error)")
        }
    }
    
    private func handleAction(_ action: BotsiAction) {
        switch action {
        case .didPurchase(let profile):
            print("✅ Purchase successful")
            showPaywall = false
        case .didRestorePurchase(let profile):
            print("✅ Restore successful")
            showPaywall = false
        case .didClose:
            showPaywall = false
        default:
            break
        }
    }
    
    private func handleError(_ error: BotsiUIError) {
        print("Error: \(error)")
    }
}
```

### With Loading State

```swift
struct PaywallView: View {
    @State private var showPaywall = false
    @State private var paywall: BotsiPaywall?
    @State private var builder: Data?
    @State private var isLoading = false
    @State private var error: String?
    
    var body: some View {
        VStack {
            if let error = error {
                Text(error).foregroundColor(.red)
            }
            
            Button("Unlock Premium") {
                Task { await loadPaywall() }
            }
            .disabled(isLoading)
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
        }
        .botsiPaywall(
            isPresented: $showPaywall,
            paywall: paywall,
            builder: builder,
            purchaseDelegate: RevenueCatPurchaseDelegate(),
            onAction: handleAction,
            onUIError: { error = $0.localizedDescription }
        )
    }
    
    private func loadPaywall() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            paywall = try await Botsi.getPaywall(from: "placement_id")
            builder = try await Botsi.getPaywallBuilder(from: paywall!)
            try await Botsi.logPaywallShown(for: paywall!)
            showPaywall = true
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func handleAction(_ action: BotsiAction) {
        switch action {
        case .didPurchase, .didRestorePurchase:
            showPaywall = false
        case .didFailPurchase(_, let error):
            self.error = error.localizedDescription
        case .didClose:
            showPaywall = false
        default:
            break
        }
    }
}
```

---

## UIKit Integration

### Basic Implementation

```swift
@available(iOS 15.0, *)
class PaywallViewController: UIViewController {
    
    private var paywall: BotsiPaywall?
    private var builder: Data?
    private let purchaseDelegate = RevenueCatPurchaseDelegate()
    
    @objc private func showPaywallTapped() {
        Task { await loadPaywall() }
    }
    
    private func loadPaywall() async {
        do {
            paywall = try await Botsi.getPaywall(from: "placement_id")
            builder = try await Botsi.getPaywallBuilder(from: paywall!)
            try await Botsi.logPaywallShown(for: paywall!)
            await presentPaywall()
        } catch {
            await showError(error.localizedDescription)
        }
    }
    
    @MainActor
    private func presentPaywall() {
        presentBotsiPaywall(
            paywall: paywall,
            builder: builder,
            purchaseDelegate: purchaseDelegate,
            onAction: { [weak self] action in
                self?.handleAction(action)
            },
            onUIError: { [weak self] error in
                self?.showError(error.localizedDescription)
            }
        )
    }
    
    private func handleAction(_ action: BotsiAction) {
        switch action {
        case .didPurchase:
            showAlert(title: "Success!", message: "Premium unlocked")
        case .didRestorePurchase:
            showAlert(title: "Restored!", message: "Purchases restored")
        case .didFailPurchase(_, let error):
            showAlert(title: "Error", message: error.localizedDescription)
        default:
            break
        }
    }
    
    @MainActor
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        Task { @MainActor in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
```

---

## Error Handling

### Handle All Action Cases

```swift
private func handleAction(_ action: BotsiAction) {
    switch action {
    case .didOpen:
        print("📱 Paywall opened")
        
    case .didPurchase(let profile):
        print("✅ Purchase completed - Profile: \(profile.profileId)")
        showPaywall = false
        
    case .didRestorePurchase(let profile):
        print("✅ Restore completed - Profile: \(profile.profileId)")
        showPaywall = false
        
    case .didFailPurchase(let product, let error):
        print("❌ Purchase failed: \(error.localizedDescription)")
        if let product = product {
            print("   Product: \(product.productId)")
        }
        
    case .didFailRestorePurchases(let error):
        print("❌ Restore failed: \(error.localizedDescription)")
        
    case .didClose:
        print("📱 Paywall closed")
        showPaywall = false
        
    case .didSelectProduct(let product):
        print("🔍 Selected product: \(product.productId)")
        
    case .didOpenURL(let url):
        print("🔗 Opened URL: \(url)")
        
    case .custom(let action):
        print("🎯 Custom action: \(action)")
        
    default:
        break
    }
}
```

### RevenueCat Error Handling

```swift
func handlePurchase(_ product: BotsiProduct) async -> BotsiPurchaseResult {
    do {
        // ... purchase logic
    } catch let error as ErrorCode {
        switch error {
        case .purchaseCancelledError:
            return .cancelled
        case .productAlreadyPurchasedError:
            return await handleRestore()
        case .networkError:
            return .failure(PurchaseError.networkError)
        case .storeProblemError:
            return .failure(PurchaseError.storeProblem)
        default:
            return .failure(error)
        }
    } catch {
        return .failure(error)
    }
}

private func handleRestore() async -> BotsiPurchaseResult {
    let result = await handleRestore()
    switch result {
    case .success(let profile):
        return .success(profile)
    case .failure(let error):
        return .failure(error)
    }
}
```

---

## Optional: Pre-Purchase Validation

Add validation logic before purchases:

```swift
extension RevenueCatPurchaseDelegate {
    
    func shouldPurchase(_ product: BotsiProduct) async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            
            // Prevent duplicate subscriptions
            if customerInfo.entitlements.active.count > 0 {
                print("⚠️ User already subscribed")
                return false
            }
            
            return true
        } catch {
            print("⚠️ Validation failed: \(error)")
            return true // Allow purchase on validation failure
        }
    }
    
    func didCompletePurchase(_ product: BotsiProduct, profile: BotsiProfile) async {
        print("✅ Purchase analytics")
        // Track with your analytics service
        // Analytics.track("purchase_completed", ["product": product.productId])
    }
}
```

---

## Complete Minimal Example

```swift
import SwiftUI
import Botsi
import RevenueCat

struct ContentView: View {
    @State private var showPaywall = false
    @State private var paywall: BotsiPaywall?
    @State private var builder: Data?
    
    var body: some View {
        Button("Show Paywall") {
            Task {
                paywall = try? await Botsi.getPaywall(from: "placement_id")
                builder = try? await Botsi.getPaywallBuilder(from: paywall!)
                try? await Botsi.logPaywallShown(for: paywall!)
                showPaywall = true
            }
        }
        .botsiPaywall(
            isPresented: $showPaywall,
            paywall: paywall,
            builder: builder,
            purchaseDelegate: RevenueCatPurchaseDelegate(),
            onAction: { action in
                if case .didPurchase = action { showPaywall = false }
                if case .didClose = action { showPaywall = false }
            },
            onUIError: { print($0) }
        )
        .task {
            Purchases.configure(withAPIKey: "rc_key")
            try? await Botsi.activate("botsi_key")
        }
    }
}
```

---

## Best Practices

### ✅ Do's
- Initialize SDKs on app launch
- Handle all action cases in `onAction`
- Provide user feedback for errors
- Log analytics events with `logPaywallShown`
- Use weak self in UIKit closures

### ❌ Don'ts
- Don't block UI during initialization
- Don't ignore error cases
- Don't skip `logPaywallShown` call
- Don't forget to dismiss paywall on success

### 🔄 Sync Considerations
- Add 1 second delay after RevenueCat purchase for backend sync
- Handle webhook delays appropriately
- Consider retry logic for profile fetching

---

## Troubleshooting

**Issue:** Products not found in RevenueCat
- Verify product IDs match between Botsi and RevenueCat
- Check RevenueCat offerings are configured correctly

**Issue:** Purchase succeeds but Botsi profile not updated
- Increase sync delay (currently 1 second)
- Verify webhook configuration between RevenueCat and Botsi

**Issue:** Restore not working
- Ensure user has made previous purchases
- Check RevenueCat restore purchases returns valid data

---

## Resources

- [Botsi SDK Documentation](https://docs.botsi.app)
- [RevenueCat Documentation](https://docs.revenuecat.com)
- [StoreKit 2 Guide](https://developer.apple.com/storekit/)

