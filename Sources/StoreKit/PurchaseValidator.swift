//
//  PurchaseValidator.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 04.10.2024
//

import Foundation

protocol PurchaseValidator: AnyObject, Sendable {
    func validatePurchase(
        profileId: String?,
        transaction: PurchasedTransaction,
        reason: Botsi.ValidatePurchaseReason
    ) async throws -> VH<BotsiProfile>

    func signSubscriptionOffer(
        profileId: String,
        vendorProductId: String,
        offerId: String
    ) async throws -> BotsiSubscriptionOffer.Signature
}

extension Botsi: PurchaseValidator {
    enum ValidatePurchaseReason: Sendable, Hashable {
        case setVariation
        case observing
        case purchasing
        case sk2Updates
    }

    func reportTransaction(
        profileId: String?,
        transactionId: String,
        variationId: String?
    ) async throws -> VH<BotsiProfile> {
        do {
            let response = try await httpSession.reportTransaction(
                profileId: profileId ?? profileStorage.profileId,
                transactionId: transactionId,
                variationId: variationId
            )
            saveResponse(response, syncedTrunsaction: true)
            return response
        } catch {
            throw error.asBotsiError ?? BotsiError.reportTransactionIdFailed(unknownError: error)
        }
    }

    func validatePurchase(
        profileId: String?,
        transaction: PurchasedTransaction,
        reason: Botsi.ValidatePurchaseReason
    ) async throws -> VH<BotsiProfile> {
        do {
            let response = try await httpSession.validateTransaction(
                profileId: profileId ?? profileStorage.profileId,
                purchasedTransaction: transaction,
                reason: reason
            )
            saveResponse(response, syncedTrunsaction: true)
            return response
        } catch {
            throw error.asBotsiError ?? BotsiError.validatePurchaseFailed(unknownError: error)
        }
    }

    func signSubscriptionOffer(
        profileId: String,
        vendorProductId: String,
        offerId: String
    ) async throws -> BotsiSubscriptionOffer.Signature {
        do {
            let response = try await httpSession.signSubscriptionOffer(
                profileId: profileId,
                vendorProductId: vendorProductId,
                offerId: offerId
            )
            return response
        } catch {
            throw error.asBotsiError ?? BotsiError.signSubscriptionOfferFailed(unknownError: error)
        }
    }
}
