//
//  BotsiHttpSession.swift
//  Botsi
//
//  Created by Vladyslav on 22.02.2025.
//

import Foundation

public struct BotsiHTTPSession: Sendable {
    let configuration: HTTPCodableConfiguration
    let requestAdditional: HTTPRequestAdditional?
    private let responseValidator: BotsiHTTPDataResponse.Validator
    private let errorHandler: HTTPErrorHandlerActor?
    private let session: URLSession
    private let requestSigner: Sign?
    
    typealias Sign = @Sendable (URLRequest, BotsiHTTPRequestPath) throws -> URLRequest

    init(
        configuration: HTTPCodableConfiguration,
        requestAdditional: HTTPRequestAdditional? = nil,
        requestSigner: Sign? = nil,
        responseValidator: @escaping BotsiHTTPDataResponse.Validator = BotsiHTTPDataResponse.defaultValidator,
        errorHandler: HTTPErrorHandler? = nil
    ) {
        self.configuration = configuration
        self.requestAdditional = requestAdditional
        self.requestSigner = requestSigner
        self.responseValidator = responseValidator
        self.errorHandler = HTTPErrorHandlerActor.init()
        
        let delegate = HTTPSessionDelegate(state: HTTPSessionState(), configuration: configuration)
        self.session = URLSession(
            configuration: configuration.sessionConfiguration,
            delegate: delegate,
            delegateQueue: nil
        )
    }

    func perform<Body: Decodable>(
        _ request: some BotsiHTTPRequest,
        withDecoder decoder: @escaping HTTPDecoder<Body>
    ) async throws -> BotsiHTTPResponse<Body> {
        let endpoint = request.endpoint
        var urlRequest: URLRequest

        do {
            urlRequest = try request.convertToURLRequest(configuration: configuration, additional: requestAdditional)
            if let signer = requestSigner {
                urlRequest = try signer(urlRequest, endpoint)
            }
        } catch {
            throw handleError(.perform(endpoint, error: error))
        }
        logRequest(urlRequest)
        
        let dataResponse = try await fetchData(urlRequest, endpoint: endpoint)
        
        if let json = try? JSONSerialization.jsonObject(with: dataResponse.data) {
            print("RAW: \(json)")
        }
        
        if let validationError = responseValidator(dataResponse) {
            throw handleError(.backend(dataResponse, error: validationError))
        }
        
        return try decodeResponse(dataResponse, with: decoder, urlRequest: urlRequest, endpoint: endpoint)
    }
    
    private func logRequest(_ request: URLRequest) {
        print("\n➡️ [REQUEST]")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Method: \(request.httpMethod ?? "nil")")

        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        } else {
            print("Headers: nil")
        }

        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        } else {
            print("Body: nil")
        }
    }
}

private extension BotsiHTTPSession {
    func fetchData(_ request: URLRequest, endpoint: BotsiHTTPRequestPath) async throws -> BotsiHTTPDataResponse {
        do {
            let (data, response) = try await session.data(for: request)
            return BotsiHTTPDataResponse(endpoint: endpoint, response: response, data: data)
        } catch {
            throw handleError(.network(endpoint, error: error))
        }
    }
    
    func decodeResponse<Body: Decodable>(
        _ response: BotsiHTTPDataResponse,
        with decoder: @escaping HTTPDecoder<Body>,
        urlRequest: URLRequest,
        endpoint: BotsiHTTPRequestPath
    ) throws -> BotsiHTTPResponse<Body> {
        let startDecoderTime = DispatchTime.now()
        do {
            var bodyResponse = try decoder(response)
            let endDecoderTime = DispatchTime.now()
            bodyResponse = bodyResponse.replaceDecodingTime(start: startDecoderTime, end: endDecoderTime)
            return bodyResponse
        } catch {
            throw handleError(.decoding(response, error: error))
        }
    }
    
    func handleError(_ error: BotsiHTTPError) -> BotsiHTTPError {
        errorHandler?.call(error)
        return error
    }
}

typealias HTTPDecoder<Body> = (BotsiHTTPDataResponse) throws -> BotsiHTTPResponse<Body>
