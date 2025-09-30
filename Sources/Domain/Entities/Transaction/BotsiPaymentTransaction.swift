//
//  BotsiPaymentTransaction.swift
//  Botsi
//
//  Created by Vladyslav on 24.02.2025.
//

import StoreKit

public struct BotsiPaymentTransaction: Sendable, CustomStringConvertible {
    public let transactionId: String
    public let originalTransactionId: String
    public let sourceProductId: String
    public let originalPrice: Decimal?
    public let priceLocale: String?
    public let storeCountry: String?
    
    public let offer: BotsiSubscriptionOffer?
    
    public let promotionalOfferId: String
    public let discountPrice: String
    public let productId: String
    public let environment: String
    
    public let paywallId: Int?
    public let abTestId: Int?
    public let placementId: String?
    public let isSubscription: Bool
    
    public var description: String {
        return """
            BotsiTransaction:
        
            transactionId: \(transactionId)
            originalTransactionId: \(originalTransactionId)
            vendorProductId: \(sourceProductId)
            price: \(originalPrice ?? 0)
            priceLocale: \(priceLocale ?? "-")
            storeCountry: \(storeCountry ?? "-")
            subscriptionOffer: \(offer.debugDescription)
        """
    }
}

extension BotsiPaymentTransaction {
    enum OfferType: Int, CustomStringConvertible {
        case unknown = 0
        case introductory = 1
        case promotional = 2
        case code = 3
        case winBack = 4
        
        var description: String {
            switch self {
            case .unknown:
                return "unknown"
            case .introductory:
                return "introductory"
            case .promotional:
                return "promotional"
            case .code:
                return "code"
            case .winBack:
                return "winBack"
            }
        }
    }
}

extension BotsiPaymentTransaction {
    static public func getEnvironmentSK1() -> String {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            return "unknown"
        }
        
        let receiptPath = appStoreReceiptURL.path
        if receiptPath.contains("sandboxReceipt") {
            return "sandbox"
        } else {
            return "production"
        }
    }
}

