//
//  BotsiValidateTransactionMapper.swift
//  Botsi
//
//  Created by Vladyslav on 10.03.2025.
//

import Foundation

struct BotsiValidateTransactionMapper: DomainMapper {
    typealias Parameters = (transaction: BotsiPaymentTransaction, profileId: String)
    
    typealias DTOResponseModel = BotsiValidateTransactionResponseDto
    
    typealias DTORequestModel = BotsiValidateTransactionRequestDto
    
    typealias DomainModel = BotsiProfile
    
    func toDTO(from parameters: Parameters) -> BotsiValidateTransactionRequestDto {
        let transaction = parameters.transaction
        return BotsiValidateTransactionRequestDto(
            transactionId: transaction.transactionId,
            originalTransactionId: transaction.originalTransactionId,
            sourceProductId: transaction.sourceProductId,
            originalPrice: transaction.originalPrice ?? -1,
            discountPrice: transaction.discountPrice,
            priceLocale: transaction.priceLocale ?? "null",
            storeCountry: transaction.storeCountry ?? "null",
            offer: BotsiValidateTransactionOfferDto(
                periodUnit: transaction.offer?.periodUnit?.unit.rawValue ?? "null",
                numberOfUnits: transaction.offer?.periodUnit?.numberOfUnits ?? -1,
                type: transaction.offer?.type.rawValue ?? "null",
                category: transaction.offer?.offerType.description ?? "null"),
            promotionalOfferId: transaction.promotionalOfferId,
            environment: transaction.environment,
            profileId: parameters.profileId,
            productId: transaction.productId,
            placementId: transaction.placementId,
            paywallId: transaction.paywallId,
            isSubscription: transaction.isSubscription
        )
    }
    
    func toDomain(from dto: BotsiValidateTransactionResponseDto) -> BotsiProfile {
        return dto.data
    }
}
