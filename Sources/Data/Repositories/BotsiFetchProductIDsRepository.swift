//
//  BotsiFetchProductIDsRepository.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//

import Foundation

protocol BotsiFetchProductIDsRepository {
    func fetchProductIds(from storeName: String) async throws -> [String]
}

final class FetchProductIDsRepository: BotsiFetchProductIDsRepository {
    private let httpClient: BotsiHttpClient

    init(httpClient: BotsiHttpClient) {
        self.httpClient = httpClient
    }

    func fetchProductIds(from storeName: String) async throws ->  [String] {
        do {
            var request = FetchProductIDsRequest(storeName: storeName)
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })
            

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let responseDto: ProductIDsDtoResponse = try wrapper.decode()
            
            return responseDto.data
        } catch {
            BotsiLog.error("Failed to fetch product identifiers: \(error.localizedDescription)")
            throw BotsiError.fetchingProductIdsFailed
        }
    }
}
