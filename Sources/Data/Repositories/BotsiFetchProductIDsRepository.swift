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
            
            print("url: \(request.relativePath) ")
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })
            

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let responseDto: ProductIDsDtoResponse = try wrapper.decode()
            
            // TODO: Store response into Profile Storage
            print("Response json: \(responseDto)")
            
            return responseDto.data
        } catch {
            print("Request failed with error: \(error)")
            throw BotsiError.userCreationFailed
        }
    }
}
