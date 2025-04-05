//
//  PaymentTransaction+Period.swift
//  Botsi
//
//  Created by Vladyslav on 05.04.2025.
//

import StoreKit

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

/// `StoreKit 1`
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

/// `StoreKit 2`
@available(iOS 15.0, *)
extension Product.SubscriptionPeriod.Unit {
    var toPeriodUnit: BotsiSubscriptionPeriod.BotsiSubscriptionPeriodUnit {
        switch self {
        case .day:
            return .day
        case .week:
            return .week
        case .month:
            return .month
        case .year:
            return .year
        default:
            return .unknown
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Product.SubscriptionOffer.PaymentMode {
    var asPaymentMode: BotsiSubscriptionOffer.BotsiPaymentMode {
        switch self {
        case .payAsYouGo:
            .payAsYouGo
        case .payUpFront:
            .payUpFront
        case .freeTrial:
            .freeTrial
        default:
            .unknown
        }
    }
}
