//
//  ProductInfoModel.swift
//
//
//  Created by Alexey Goncharov on 27.7.23..
//

#if canImport(UIKit)

import Botsi
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
protocol ProductInfoModel {
    var anyProduct: BotsiPaywallProductWithoutDeterminingOffer { get }
    var botsiProductId: String { get }
    var botsiProduct: BotsiPaywallProduct? { get }

    var paymentMode: BotsiSubscriptionOffer.PaymentMode { get }

    func stringByTag(_ tag: VC.ProductTag) -> VC.ProductTagReplacement?
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
enum BotsiPaywallProductWrapper {
    case withoutOffer(BotsiPaywallProductWithoutDeterminingOffer)
    case full(BotsiPaywallProduct)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension BotsiPaywallProductWrapper: ProductInfoModel {
    var anyProduct: BotsiPaywallProductWithoutDeterminingOffer {
        switch self {
        case .withoutOffer(let v): v
        case .full(let v): v
        }
    }

    func isApplicableForTag(_ tag: VC.ProductTag) -> Bool {
        switch tag {
        case .title, .price:
            return true
        case .pricePerDay, .pricePerWeek, .pricePerMonth, .pricePerYear:
            return anyProduct.subscriptionPeriod != nil
        case .offerPrice, .offerPeriods, .offerNumberOfPeriods:
            return botsiProduct?.subscriptionOffer != nil
        }
    }

    var botsiProductId: String { anyProduct.botsiProductId }

    var botsiProduct: BotsiPaywallProduct? {
        switch self {
        case .withoutOffer: nil
        case .full(let v): v
        }
    }

    var paymentMode: BotsiSubscriptionOffer.PaymentMode {
        botsiProduct?.subscriptionOffer?.paymentMode ?? .unknown
    }

    func stringByTag(_ tag: VC.ProductTag) -> VC.ProductTagReplacement? {
        guard isApplicableForTag(tag) else { return .notApplicable }

        let result: String?
        switch tag {
        case .title:
            result = anyProduct.localizedTitle
        case .price:
            result = anyProduct.localizedPrice
        case .pricePerDay:
            result = anyProduct.pricePer(period: .day)
        case .pricePerWeek:
            result = anyProduct.pricePer(period: .week)
        case .pricePerMonth:
            result = anyProduct.pricePer(period: .month)
        case .pricePerYear:
            result = anyProduct.pricePer(period: .year)
        case .offerPrice:
            result = botsiProduct?.subscriptionOffer?.localizedPrice
        case .offerPeriods:
            result = botsiProduct?.subscriptionOffer?.localizedSubscriptionPeriod
        case .offerNumberOfPeriods:
            result = botsiProduct?.subscriptionOffer?.localizedNumberOfPeriods
        }

        if let result = result {
            return .value(result)
        } else {
            return nil
        }
    }
}

#endif
