//
//  BackendExecutor.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 04.04.2023
//

import Foundation

protocol BackendExecutor: Sendable {
    var session: HTTPSession { get }
}

extension BackendExecutor {
    @BotsiActor
    @inlinable
    func perform<Request: HTTPRequestWithDecodableResponse>(
        _ request: Request,
        requestName: APIRequestName,
        logParams: EventParameters? = nil
    ) async throws -> Request.Response {
        let stamp = request.stamp
        Botsi.trackSystemEvent(BotsiBackendAPIRequestParameters(requestName: requestName, requestStamp: stamp, params: logParams))
        do {
            let response: Request.Response = try await session.perform(request)
            Botsi.trackSystemEvent(BotsiBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, response))
            return response
        } catch {
            Botsi.trackSystemEvent(BotsiBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, error))
            throw error
        }
    }

    @BotsiActor
    @inlinable
    func perform(
        _ request: some HTTPRequest,
        requestName: APIRequestName,
        logParams: EventParameters? = nil
    ) async throws -> HTTPEmptyResponse {
        let stamp = request.stamp
        Botsi.trackSystemEvent(BotsiBackendAPIRequestParameters(requestName: requestName, requestStamp: stamp, params: logParams))
        do {
            let response: HTTPEmptyResponse = try await session.perform(request)
            Botsi.trackSystemEvent(BotsiBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, response))
            return response
        } catch {
            Botsi.trackSystemEvent(BotsiBackendAPIResponseParameters(requestName: requestName, requestStamp: stamp, error))
            throw error
        }
    }
}
