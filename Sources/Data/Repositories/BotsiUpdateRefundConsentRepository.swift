//
//  BotsiUpdateRefundConsentRepository.swift
//  Botsi
//
//  Created by Vladyslav on 19.07.2025.
//

import Foundation

protocol BotsiUpdateRefundConsentRepository {
    func updateRefundConsent(
        for profile: String,
        consent: Bool
    ) async throws
}

final class UpdateRefundConsentRepository: BotsiUpdateRefundConsentRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: BotsiUpdateRefundConsentMapper

    init(httpClient: BotsiHttpClient, mapper: BotsiUpdateRefundConsentMapper = BotsiUpdateRefundConsentMapper()) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func updateRefundConsent(
        for profile: String,
        consent: Bool
    ) async throws {
        do {
            var request = UpdateRefundConsentRequest(profileId: profile)
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            
            let body = try mapper.toDTO(from: consent).toData()
            request.body = body
            
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            do {
                let responseDto: UpdateAppleConsumptionConsentResponseDto = try wrapper.decode()
                if responseDto.ok {
                    BotsiLog.info("Refund consent status for the user has been updated.")
                }
                return
            } catch {
                let errorDto: CreateProfileErrorDtoResponse = try wrapper.decode()
                if errorDto.status == 403 {
                    throw BotsiError.sdkActivationKeyNotValid
                } else {
                    throw BotsiError.customError(errorDto.message, "Status code: \(errorDto.status)")
                }
            }
        } catch let error as BotsiError {
            BotsiLog.error("Failed to update user refund data consent status for profile \(profile) with error: \(error.localizedDescription)")
            throw error
        } catch {
            throw BotsiError.userGetProfileFailed
        }
    }
}

