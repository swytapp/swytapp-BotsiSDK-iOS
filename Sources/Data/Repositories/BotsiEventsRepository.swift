//
//  BotsiEventsRepository.swift
//  Botsi
//
//  Created by Vladyslav on 25.03.2025.
//

import Foundation

protocol BotsiEventsRepository {
    func sendEvent(
        profileId: String,
        paywallId: Int?,
        abTestId: Int?,
        eventType: String,
        placementId: String
    ) async throws
}

final class EventsRepository: BotsiEventsRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: BotsiEventMapper

    init(httpClient: BotsiHttpClient, mapper: BotsiEventMapper = BotsiEventMapper()) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func sendEvent(
        profileId: String,
        paywallId: Int? = nil,
        abTestId: Int? = nil,
        eventType: String,
        placementId: String
    ) async throws {
        do {
            var request = SendEventRequest()
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            let parameters = (profileId, paywallId, abTestId, eventType, placementId)
            let body = try mapper.toDTO(from: parameters).toData()
            request.body = body
            
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })
            

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let _: BotsiEventsResponseDto = try wrapper.decode()
        } catch {
            throw BotsiError.eventsError
        }
    }
}
