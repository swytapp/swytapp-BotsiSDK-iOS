//
//  BotsiValidateTransactionMapper.swift
//  Botsi
//
//  Created by Vladyslav on 10.03.2025.
//

import Foundation

struct BotsiValidateTransactionMapper: DomainMapper {
    typealias Parameters = (transaction: BotsiPaymentTransaction, profileId: String, source: String, isExperiment: Bool, aiPricingModelId: Int)
    
    typealias DTOResponseModel = BotsiValidateTransactionResponseDto
    
    typealias DTORequestModel = BotsiValidateTransactionRequestDto
    
    typealias DomainModel = BotsiProfile
    
    func toDTO(from parameters: Parameters) -> BotsiValidateTransactionRequestDto {
        let transaction = parameters.transaction
        var offer: BotsiValidateTransactionOfferDto? = nil
        if let transactionOffer = transaction.offer,
            transactionOffer.offerType != .unknown {
            let offerDto = BotsiValidateTransactionOfferDto(
                periodUnit: transaction.offer?.periodUnit?.unit.rawValue,
                numberOfUnits: transaction.offer?.periodUnit?.numberOfUnits,
                type: transaction.offer?.type.rawValue,
                category: transaction.offer?.offerType.description)
            offer = offerDto
        }
        return BotsiValidateTransactionRequestDto(
            transactionId: transaction.transactionId,
            originalTransactionId: transaction.originalTransactionId,
            sourceProductId: transaction.sourceProductId,
            originalPrice: transaction.originalPrice,
            discountPrice: transaction.discountPrice,
            priceLocale: transaction.priceLocale,
            storeCountry: transaction.storeCountry,
            offer: offer,
            promotionalOfferId: transaction.promotionalOfferId,
            environment: transaction.environment,
            profileId: parameters.profileId,
            productId: transaction.productId,
            placementId: transaction.placementId,
            paywallId: transaction.paywallId,
            abTestId: transaction.abTestId,
            isSubscription: transaction.isSubscription,
            source: parameters.source,
            isExperiment: parameters.isExperiment,
            aiPricingModelId: parameters.aiPricingModelId
        )
    }
    
    func toDomain(from dto: BotsiValidateTransactionResponseDto) -> BotsiProfile {
        return dto.data
    }
}
