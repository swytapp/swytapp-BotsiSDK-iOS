**Botsi iOS SDK**

A powerful Swift SDK for:
- In-App Purchase Management
- Paywall Configuration & Analytics
- Built with async/await, clean architecture, and production-ready best practices.

**🚀 Key Features**

  Unified In-App Purchases
  - Fetch products and handle transactions via StoreKit
  - Introductory and promotional offer support
  - Restore purchases and maintain user entitlements
  
  Paywall Management
  - Fetch associated products and pricing
  - Log paywall impressions for analytics
  
  Modern Swift API
  - All APIs exposed as async functions
  - Non-blocking, main-thread friendly design

**📦 Installation**

**CocoaPods**

Add to your Podfile:

`pod 'Botsi', '~> 1.0.8'`

Then run:

`pod install`

**Swift Package Manager (SPM)**

In Xcode, choose File → Swift Packages → Add Package Dependency

Enter:

`https://github.com/BotsiTeam/BotsiSDK-iOS.git`

Select Up to Next Major version 1.0.7

**🛠 Quick Start**

```
import Botsi

Task {
    // 1. Activate SDK
    try await Botsi.activate("YOUR_PUBLIC_API_KEY")

    // 2. (Optional) Identify user
    try await Botsi.identify("user_123")

    // 3. Fetch available products
    let paywall = try await Botsi.getPaywall(from: "placement_id")
    let products = try await Botsi.getPaywallProducts(from: paywall)
    print("Available: \(products)")

    // 4. Make a purchase
    let profile = try await Botsi.makePurchase(products.first!)
    print("Purchased: \(profile)")

    // 5. Restore purchases
    let restoredProfile = try await Botsi.restorePurchases()
    print("Restored: \(restoredProfile)")
}
```

**📑 Documentation**

Detailed API reference, guides, and examples are in the [botsi-documentation.md](https://github.com/BotsiTeam/BotsiSDK-iOS/blob/1.0.4/botsi-documentation.md)


**🤝 Contributing**

Contributions are welcome! Please open issues or pull requests on the GitHub repository.

**📜 License**

This SDK is released under the MIT License. Feel free to use, modify, and distribute as needed.
