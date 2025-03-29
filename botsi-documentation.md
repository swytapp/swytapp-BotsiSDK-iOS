# Botsi iOS SDK Documentation

The Botsi SDK enables seamless in-app purchases and paywall management in iOS applications. This documentation covers the public API methods available for integration.

## Table of Contents
- [Installation](#installation)
- [Initialization](#initialization)
- [Profile Management](#profile-management)
- [Product Management](#product-management)
- [Purchase Operations](#purchase-operations)
- [Paywall Management](#paywall-management)

## Initialization

### `activate(with:)`
```swift
static func activate(with config: BotsiConfiguration) async throws
```

Activates and initializes the Botsi SDK with your configuration.

**Parameters:**
- `config`: A `BotsiConfiguration` object containing your SDK API key and observer settings.

**Example:**
```swift
do {
    try await Botsi.activate(with: BotsiConfiguration(
        sdkApiKey: "your_api_key",
        enableObserver: true
    ))
    // SDK is now initialized and ready for use
} catch {
    print("Failed to initialize Botsi SDK: \(error)")
}
```

### `isInitialized`
```swift
static var isInitialized: Bool { get async }
```

Checks if the Botsi SDK has been properly initialized.

**Returns:**
- `Bool`: `true` if the SDK has been initialized, `false` otherwise.

**Example:**
```swift
let initialized = await Botsi.isInitialized
if initialized {
    // SDK is ready to use
} else {
    // SDK needs to be initialized
}
```

## Profile Management

### `getProfile()`
```swift
static func getProfile() async throws -> BotsiProfile
```

Retrieves the current user's profile information.

**Returns:**
- `BotsiProfile`: The user's profile with information about their purchases and entitlements.

**Throws:**
- `BotsiError.userProfileNotFound`: If no profile has been created for the current user.

**Example:**
```swift
do {
    let profile = try await Botsi.getProfile()
    print("User profile ID: \(profile.profileId)")
    // Access other profile properties
} catch {
    print("Failed to get user profile: \(error)")
}
```

## Product Management

### `fetchProductIDs()`
```swift
static func fetchProductIDs() async throws -> [String]
```

Retrieves the list of product IDs available for the application.

**Returns:**
- `[String]`: Array of product identifiers that can be used for purchases.

**Example:**
```swift
do {
    let productIDs = try await Botsi.fetchProductIDs()
    print("Available product IDs: \(productIDs)")
} catch {
    print("Failed to fetch product IDs: \(error)")
}
```

## Purchase Operations

### `makePurchase(_:)`
```swift
static func makePurchase(_ productId: String) async throws -> BotsiProfile
```

Initiates a purchase for the specified product ID.

**Parameters:**
- `productId`: The identifier of the product to purchase.

**Returns:**
- `BotsiProfile`: Updated user profile after the purchase is complete.

**Throws:**
- `BotsiError.transactionFailed`: If the purchase transaction fails.
- `BotsiError.customError`: With details if there are issues with StoreKit handlers.

**Example:**
```swift
do {
    let updatedProfile = try await Botsi.makePurchase("premium_subscription")
    // Handle successful purchase
    print("Purchase successful! Updated profile: \(updatedProfile.profileId)")
} catch {
    print("Purchase failed: \(error)")
}
```

### `restorePurchases()`
```swift
static func restorePurchases() async throws -> BotsiProfile
```

Restores previously purchased products for the current user.

**Returns:**
- `BotsiProfile`: Updated user profile with restored purchases.

**Throws:**
- `BotsiError.restoreFailed`: If the restore operation fails.

**Example:**
```swift
do {
    let restoredProfile = try await Botsi.restorePurchases()
    print("Purchases restored successfully!")
    // Check restored entitlements
} catch {
    print("Failed to restore purchases: \(error)")
}
```

## Paywall Management

### `getPaywall(from:)`
```swift
static func getPaywall(from placementId: String) async throws -> BotsiPaywall
```

Retrieves a paywall configuration for the specified placement ID.

**Parameters:**
- `placementId`: The identifier of the paywall placement.

**Returns:**
- `BotsiPaywall`: The paywall configuration with UI elements and product references.

**Throws:**
- `BotsiError.userProfileNotFound`: If no user profile exists.

**Example:**
```swift
do {
    let paywall = try await Botsi.getPaywall(from: "main_screen_premium")
    // Configure your UI with the paywall information
    print("Paywall retrieved: \(paywall)")
} catch {
    print("Failed to get paywall: \(error)")
}
```

### `getPaywallProducts(from:)`
```swift
static func getPaywallProducts(from paywall: BotsiPaywall) async throws -> [BotsiProduct]
```

Retrieves detailed product information for all products in a paywall.

**Parameters:**
- `paywall`: A `BotsiPaywall` object obtained from `getPaywall(from:)`.

**Returns:**
- `[BotsiProduct]`: Array of product details including pricing, description, and other StoreKit information.

**Example:**
```swift
do {
    let paywall = try await Botsi.getPaywall(from: "main_screen_premium")
    let products = try await Botsi.getPaywallProducts(from: paywall)
    
    // Display products to the user
    for product in products {
        print("Product: \(product.title)")
        print("Price: \(product.price)")
        // Configure purchase buttons with product information
    }
} catch {
    print("Failed to get paywall products: \(error)")
}
```

## Error Handling

The SDK uses `BotsiError` for error reporting. Common errors include:

- `BotsiError.userProfileNotFound`: No profile exists for the current user
- `BotsiError.transactionFailed`: Purchase transaction failed
- `BotsiError.restoreFailed`: Restore purchases operation failed
- `BotsiError.customError`: Custom errors with detailed information
- `BotsiError.paywallFetchingFailed`: Failed to fetch paywall information
    

Properly handle these errors in your application to provide appropriate feedback to users.
