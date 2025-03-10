//
//  BotsiPaymentTransaction.swift
//  Botsi
//
//  Created by Vladyslav on 24.02.2025.
//

import StoreKit

public struct BotsiPaymentTransaction: Sendable, CustomStringConvertible {
    public var description: String {
        return """
            BotsiPaymentTransaction:
        
            transactionId: \(transactionId)
            originalTransactionId: \(originalTransactionId)
            vendorProductId: \(sourceProductId)
            price: \(originalPrice ?? 0)
            priceLocale: \(priceLocale ?? "-")
            storeCountry: \(storeCountry ?? "-")
            subscriptionOffer: \(offer.debugDescription)
        
        """
    }
    
    enum OfferType: Int, CustomStringConvertible {
        case unknown = 0
        case introductory = 1
        case promotional = 2
        case code = 3
        case winBack = 4
        
        var description: String {
            switch self {
            case .unknown: return "unknown"
            case .introductory: return "introductory"
            case .promotional: return "promotional"
            case .code: return "code"
            case .winBack: return "winBack"
            }
        }
    }
    
    // MARK: Main transaction content
    let transactionId: String
    let originalTransactionId: String
    let sourceProductId: String
    let originalPrice: Decimal?
    let priceLocale: String?
    let storeCountry: String?
    
    let offer: BotsiSubscriptionOffer?
    
    let promotionalOfferId: String
    let discountPrice: String
    let productId: String
    let environment: String
    
    /// `hardcoded`
    let paywallId: String = "somePaywallId"
    let placementId: String = "somePlacementId"
    let isSubscription: Bool = true
    
    init(with product: SKProduct, transaction: SKPaymentTransaction) {
        let offer = BotsiSubscriptionOffer(transaction: transaction, product: product)
        self.transactionId = transaction.transactionIdentifier ?? transaction.original?.transactionIdentifier ?? ""
        self.originalTransactionId = transaction.original?.transactionIdentifier ?? transaction.transactionIdentifier ?? ""
        self.sourceProductId = transaction.payment.productIdentifier
        self.originalPrice = product.price.decimalValue
        self.priceLocale = product.priceLocale.currencyCode
        self.storeCountry = product.priceLocale.regionCode
        self.offer = offer
        self.promotionalOfferId = offer?.id ?? ""
        self.discountPrice = "\(offer?.price ?? 0)"
        self.productId = product.productIdentifier
        self.environment = BotsiPaymentTransaction.getEnvironmentSK1()
    }
    
    @available(iOS 15.0, *)
    init(with product: Product, transaction: Transaction) {
        
        let offer = BotsiSubscriptionOffer(transaction: transaction, product: product)
        self.transactionId = String(transaction.id)
        self.originalTransactionId = String(transaction.originalID)
        self.sourceProductId = transaction.productID
        self.originalPrice = Decimal(string: product.price.description)
        self.priceLocale = product.priceFormatStyle.currencyCode
        if #available(macOS 13, *) {
            if #available(iOS 16, *) {
                self.storeCountry = Locale.current.region?.identifier
                switch transaction.environment {
                case .sandbox:
                    self.environment = "Sandbox"
                case .production:
                    self.environment = "Production"
                default:
                    self.environment = "Unknown"
                }
            } else {
                self.storeCountry = product.subscriptionPeriodFormatStyle.locale.identifier
                self.environment = BotsiPaymentTransaction.getEnvironmentSK1()
            }
            
        } else {
            self.storeCountry = product.subscriptionPeriodFormatStyle.locale.identifier
            self.environment = BotsiPaymentTransaction.getEnvironmentSK1()
        }
        self.offer = offer
        self.promotionalOfferId = offer?.id ?? ""
        self.discountPrice = "\(offer?.price ?? 0)"
        self.productId = product.id
    }
}

// MARK: Offer
public struct BotsiSubscriptionOffer: Sendable, CustomStringConvertible {
    
    public var description: String {
        return """
            id: \(id ?? "-")
            period: \(periodUnit.debugDescription)
            paymentMode: \(type)
            offerType: \(offerType)
            price: \(price ?? 0)
        """
    }
    
    public enum BotsiPaymentMode: String, Sendable {
        case payAsYouGo
        case payUpFront
        case freeTrial
        case unknown
    }
    
    let id: String?
    let periodUnit: BotsiSubscriptionPeriod?
    let type: BotsiPaymentMode
    let offerType: BotsiPaymentTransaction.OfferType
    let price: Decimal?

    init(
        id: String,
        offerType: BotsiPaymentTransaction.OfferType
    ) {
        self.id = id
        periodUnit = nil
        type = .unknown
        self.offerType = offerType
        price = nil
    }
    
    init(
        id: String?,
        period: BotsiSubscriptionPeriod?,
        paymentMode: BotsiPaymentMode,
        offerType: BotsiPaymentTransaction.OfferType,
        price: Decimal?
    ) {
        self.id = id
        self.periodUnit = period
        self.type = paymentMode
        self.offerType = offerType
        self.price = price
    }
    
    init?(
        transaction: SKPaymentTransaction,
        product: SKProduct?
    ) {
        guard let offerId = transaction.transactionIdentifier else {
            let discount = product?.subscriptionOffer( // SKProductDiscount
                byType: .introductory
            )

            guard let discount else { return nil } // SKProductDiscount

            self.init(
                id: nil,
                period: discount.subscriptionPeriod.toCustomPeriod,
                paymentMode: discount.paymentMode.asPaymentMode,
                offerType: .introductory,
                price: discount.price.decimalValue
            )
            return
        }

        let discount = product?.subscriptionOffer(
            byType: .promotional,
            withId: offerId
        )

        if let discount {
            self.init(
                id: discount.identifier,
                period: discount.subscriptionPeriod.toCustomPeriod,
                paymentMode: discount.paymentMode.asPaymentMode,
                offerType: .promotional,
                price: discount.price.decimalValue
            )
        } else {
            self.init(id: offerId, offerType: .promotional)
        }
    }
    
    @available(iOS 15.0, *)
    init?(
        transaction: Transaction,
        product: Product?
    ) {
        self.init(id: transaction.offerID, period: .none, paymentMode: .payAsYouGo, offerType: .unknown, price: transaction.price)
    }
}



// MARK: - Subscription period
public struct BotsiSubscriptionPeriod: Sendable, Hashable {
    
    public enum BotsiSubscriptionPeriodUnit: String, Sendable, Hashable {
        case day
        case week
        case month
        case year
        case unknown
    }
    
    public let unit: BotsiSubscriptionPeriodUnit
    public let numberOfUnits: Int

    init(unit: BotsiSubscriptionPeriodUnit, numberOfUnits: Int) {
        switch unit {
        case .day where numberOfUnits.isMultiple(of: 7):
            self.numberOfUnits = numberOfUnits / 7
            self.unit = .week
        case .month where numberOfUnits.isMultiple(of: 12):
            self.numberOfUnits = numberOfUnits / 12
            self.unit = .year
        default:
            self.numberOfUnits = numberOfUnits
            self.unit = unit
        }
    }
}


// MARK: - Extensions
extension SKProduct {
    func subscriptionOffer(
        byType offerType: BotsiPaymentTransaction.OfferType,
        withId offerId: String? = nil
    ) -> SKProductDiscount? {
        switch offerType {
        case .introductory:
            return introductoryPrice
        case .promotional:
            if let offerId {
                return discounts.first(where: { $0.identifier == offerId })
            }
        default:
            return nil
        }
        return nil
    }
}

extension SKProductSubscriptionPeriod {
    var toCustomPeriod: BotsiSubscriptionPeriod {
        .init(unit: unit.asCutomPerioudUnit, numberOfUnits: numberOfUnits)
    }

}

extension SKProductDiscount.PaymentMode {
    var asPaymentMode: BotsiSubscriptionOffer.BotsiPaymentMode {
        switch self {
        case .payAsYouGo:
            .payAsYouGo
        case .payUpFront:
            .payUpFront
        case .freeTrial:
            .freeTrial
        @unknown default:
            .unknown
        }
    }
}

extension SKProduct.PeriodUnit {
    var asCutomPerioudUnit: BotsiSubscriptionPeriod.BotsiSubscriptionPeriodUnit {
        switch self {
        case .day: .day
        case .week: .week
        case .month: .month
        case .year: .year
        @unknown default: .unknown
        }
    }
}

extension BotsiPaymentTransaction {
    static private func getEnvironmentSK1() -> String {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            return "Unknown"
        }
        
        let receiptPath = appStoreReceiptURL.path
        if receiptPath.contains("sandboxReceipt") {
            return "Sandbox"
        } else {
            return "Production"
        }
    }
}
