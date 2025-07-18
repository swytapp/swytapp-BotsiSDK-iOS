//
//  BotsiObjCBridge.swift
//  Botsi
//
//  Created by Vladyslav on 19.02.2025.
//

import Foundation

@objc(BotsiObjCProfile)
public class BotsiObjCProfile: NSObject {
    @objc public let profileId: String
    @objc public let customerUserId: String?
    @objc public let accessLevels: [String: Any]
    @objc public let subscriptions: [String: Any]
    @objc public let nonSubscriptions: [String: Any]
    @objc public let custom: [Any]
    
    @objc public init(profileId: String, customerUserId: String?, accessLevels: [String: Any], subscriptions: [String: Any], nonSubscriptions: [String: Any], custom: [Any]) {
        self.profileId = profileId
        self.customerUserId = customerUserId
        self.accessLevels = accessLevels
        self.subscriptions = subscriptions
        self.nonSubscriptions = nonSubscriptions
        self.custom = custom
        super.init()
    }
    
    convenience init(swift: BotsiProfile) {
        // Convert Swift types to Objective-C compatible types
        let accessLevelsDict = swift.accessLevels.mapValues { $0 as Any }
        let subscriptionsDict = swift.subscriptions.mapValues { $0 as Any }
        let nonSubscriptionsDict = swift.nonSubscriptions.mapValues { $0 as Any }
        let customArray = swift.custom.map { $0 as Any }
        
        self.init(profileId: swift.profileId,
                  customerUserId: swift.customerUserId,
                  accessLevels: accessLevelsDict,
                  subscriptions: subscriptionsDict,
                  nonSubscriptions: nonSubscriptionsDict,
                  custom: customArray)
    }
}

@objc(BotsiObjCProduct)
public class BotsiObjCProduct: NSObject {
    @objc public let productId: String
    @objc public let title: String
    @objc public let descriptionText: String
    @objc public let price: NSDecimalNumber
    @objc public let currencyCode: String?
    @objc public let localizedPrice: String?
    @objc public let introductoryPrice: String?
    @objc public let subscriptionGroupIdentifier: String?
    @objc public let localizedSubscriptionPeriod: String?
    @objc public let isEligibleForIntroOffer: Bool
    
    let swiftProduct: BotsiProduct
    
    public init(productId: String, title: String, descriptionText: String, price: NSDecimalNumber, currencyCode: String?, localizedPrice: String?, introductoryPrice: String?, subscriptionGroupIdentifier: String?, localizedSubscriptionPeriod: String?, isEligibleForIntroOffer: Bool, swiftProduct: BotsiProduct) {
        self.productId = productId
        self.title = title
        self.descriptionText = descriptionText
        self.price = price
        self.currencyCode = currencyCode
        self.localizedPrice = localizedPrice
        self.introductoryPrice = introductoryPrice
        self.subscriptionGroupIdentifier = subscriptionGroupIdentifier
        self.localizedSubscriptionPeriod = localizedSubscriptionPeriod
        self.isEligibleForIntroOffer = isEligibleForIntroOffer
        self.swiftProduct = swiftProduct
        super.init()
    }
    
    convenience init(swift: BotsiProduct) {
        self.init(productId: swift.productId,
                  title: swift.title,
                  descriptionText: swift.descriptionText,
                  price: NSDecimalNumber(decimal: swift.price),
                  currencyCode: swift.currencyCode,
                  localizedPrice: swift.localizedPrice,
                  introductoryPrice: swift.introductoryPrice,
                  subscriptionGroupIdentifier: swift.subscriptionGroupIdentifier,
                  localizedSubscriptionPeriod: swift.localizedSubscriptionPeriod,
                  isEligibleForIntroOffer: swift.isEligibleForIntroOffer,
                  swiftProduct: swift)
    }
}

@objc(BotsiObjCPaywall)
public class BotsiObjCPaywall: NSObject {
    @objc public let placementId: String
    @objc public let paywallId: Int
    @objc public let name: String
    @objc public let remoteConfigs: String?
    @objc public let revision: Int
    @objc public let abTestId: Int
    let swiftPaywall: BotsiPaywall
    
    public init(placementId: String, paywallId: Int, name: String, remoteConfigs: String?, revision: Int, abTestId: Int, swiftPaywall: BotsiPaywall) {
        self.placementId = placementId
        self.paywallId = paywallId
        self.name = name
        self.remoteConfigs = remoteConfigs
        self.revision = revision
        self.abTestId = abTestId
        self.swiftPaywall = swiftPaywall
        super.init()
    }
    
    convenience init(swift: BotsiPaywall) {
        self.init(placementId: swift.placementId,
                  paywallId: swift.id,
                  name: swift.name,
                  remoteConfigs: swift.remoteConfigs,
                  revision: swift.revision,
                  abTestId: swift.abTestId ?? 0,
                  swiftPaywall: swift)
    }
}

@objc(BotsiObjCError)
public class BotsiObjCError: NSObject {
    @objc public let localizedDescription: String
    @objc public let errorCode: String
    
    @objc public init(localizedDescription: String, errorCode: String) {
        self.localizedDescription = localizedDescription
        self.errorCode = errorCode
        super.init()
    }
    
    convenience init(swift: Error) {
        let nsError = swift as NSError
        self.init(localizedDescription: nsError.localizedDescription, errorCode: "\(nsError.domain)-\(nsError.code)")
    }
}

@objc(BotsiObjCSDK)
public class BotsiObjCSDK: NSObject {
    @objc public static func activate(_ key: String, completion: @escaping @Sendable (BotsiObjCError?) -> Void) {
        Task {
            do {
                try await Botsi.activate(key)
                completion(nil)
            } catch {
                completion(BotsiObjCError(swift: error))
            }
        }
    }
    
    @objc public static func getProfile(completion: @escaping @Sendable (BotsiObjCProfile?, BotsiObjCError?) -> Void) {
        Task {
            do {
                let profile = try await Botsi.getProfile()
                completion(BotsiObjCProfile(swift: profile), nil)
            } catch {
                completion(nil, BotsiObjCError(swift: error))
            }
        }
    }
    
    @objc public static func getPaywall(from placementId: String, completion: @escaping @Sendable (BotsiObjCPaywall?, BotsiObjCError?) -> Void) {
        Task {
            do {
                let paywall = try await Botsi.getPaywall(from: placementId)
                completion(BotsiObjCPaywall(swift: paywall), nil)
            } catch {
                completion(nil, BotsiObjCError(swift: error))
            }
        }
    }
    
    @objc public static func getPaywallProducts(from paywall: BotsiObjCPaywall, completion: @escaping @Sendable ([BotsiObjCProduct]?, BotsiObjCError?) -> Void) {
        let swiftPaywall = paywall.swiftPaywall
        Task {
            do {
                let products = try await Botsi.getPaywallProducts(from: swiftPaywall)
                let objcProducts = products.map { BotsiObjCProduct(swift: $0) }
                completion(objcProducts, nil)
            } catch {
                completion(nil, BotsiObjCError(swift: error))
            }
        }
    }
    
    @objc public static func makePurchase(_ product: BotsiObjCProduct, completion: @escaping @Sendable (BotsiObjCProfile?, BotsiObjCError?) -> Void) {
        let swiftProduct = product.swiftProduct
        Task {
            do {
                let updatedProfile = try await Botsi.makePurchase(swiftProduct)
                completion(BotsiObjCProfile(swift: updatedProfile), nil)
            } catch {
                completion(nil, BotsiObjCError(swift: error))
            }
        }
    }
    
    @objc public static func identify(_ userId: String, completion: @escaping @Sendable (BotsiObjCError?) -> Void) {
        Task {
            do {
                try await Botsi.identify(userId)
                completion(nil)
            } catch {
                completion(BotsiObjCError(swift: error))
            }
        }
    }
    
    @objc public static func logout(completion: @escaping @Sendable (BotsiObjCError?) -> Void) {
        Task {
            do {
                try await Botsi.logout()
                completion(nil)
            } catch {
                completion(BotsiObjCError(swift: error))
            }
        }
    }
    
    @objc public static func restorePurchases(completion: @escaping @Sendable (BotsiObjCProfile?, BotsiObjCError?) -> Void) {
        Task {
            do {
                let profile = try await Botsi.restorePurchases()
                completion(BotsiObjCProfile(swift: profile), nil)
            } catch {
                completion(nil, BotsiObjCError(swift: error))
            }
        }
    }
    
    @objc public static func logPaywallShown(_ paywall: BotsiObjCPaywall, completion: @escaping @Sendable (BotsiObjCError?) -> Void) {
        let swiftPaywall = paywall.swiftPaywall
        Task {
            do {
                try await Botsi.logPaywallShown(for: swiftPaywall)
                completion(nil)
            } catch {
                completion(BotsiObjCError(swift: error))
            }
        }
    }
} 
