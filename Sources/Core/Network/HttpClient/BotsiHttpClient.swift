//
//  BotsiHttpClient.swift
//  Botsi
//
//  Created by Vladyslav on 21.02.2025.
//

import Foundation

// MARK: - Backend
public struct BotsiHttpClient: Sendable {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()
    
     private let session: HTTPSession
    
    struct URLConstants {
        static let backendHost: URL = URL(string: "")!
    }
    
    init(with configuration: BotsiConfiguration) {
        let config = HTTPCodableConfiguration(sessionConfiguration: .default)
        let errorHandler = HTTPErrorHandler()
        let session = HTTPSession(configuration: config, errorHandler: errorHandler)
        self.session = session
    }
    
    func createUserProfile() async {
    do {
           let request = CreateProfileRequest()
           let response: HTTPResponse<Data> = try await session.perform(request, withDecoder: { dataResponse in
               return HTTPResponse(body: dataResponse.data)
           })
           print("Response Data: \(response.body)")
       } catch {
           print("Request failed with error: \(error)")
       }
    }
}

struct CreateProfileRequest: HTTPRequest {
    var endpoint: HTTPEndpoint = HTTPEndpoint(url: URL(string: "https://rickandmortyapi.com/api/location/3")!)
    
    var method: String = "GET"
    
    var headers: [String: String] = [:]
    
    var body: Data? = nil
    
    func convertToURLRequest(configuration: HTTPCodableConfiguration, additional: (any HTTPRequestAdditional)?) throws -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}


// MARK: - HTTP Session logic

@globalActor
actor HTTPSessionActor {
    static let shared = HTTPSessionActor()
    private var _state = HTTPSessionState()
}

struct HTTPSession: Sendable {
    let configuration: HTTPCodableConfiguration
    let requestAdditional: HTTPRequestAdditional?
    private let responseValidator: HTTPDataResponse.Validator
    private let errorHandler: HTTPErrorHandlerActor?
    private let session: URLSession
    private let requestSigner: Sign?
    
    typealias Sign = @Sendable (URLRequest, HTTPEndpoint) throws -> URLRequest

    init(
        configuration: HTTPCodableConfiguration,
        requestAdditional: HTTPRequestAdditional? = nil,
        requestSigner: Sign? = nil,
        responseValidator: @escaping HTTPDataResponse.Validator = HTTPDataResponse.defaultValidator,
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
        _ request: some HTTPRequest,
        withDecoder decoder: @escaping HTTPDecoder<Body>
    ) async throws -> HTTPResponse<Body> {
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
        
        let dataResponse = try await fetchData(urlRequest, endpoint: endpoint)
        
        if let validationError = responseValidator(dataResponse) {
            throw handleError(.backend(dataResponse, error: validationError))
        }
        
        return try decodeResponse(dataResponse, with: decoder, urlRequest: urlRequest, endpoint: endpoint)
    }
}

private extension HTTPSession {
    func fetchData(_ request: URLRequest, endpoint: HTTPEndpoint) async throws -> HTTPDataResponse {
        do {
            let (data, response) = try await session.data(for: request)
            return HTTPDataResponse(endpoint: endpoint, response: response, data: data)
        } catch {
            throw handleError(.network(endpoint, error: error))
        }
    }
    
    func decodeResponse<Body: Decodable>(
        _ response: HTTPDataResponse,
        with decoder: @escaping HTTPDecoder<Body>,
        urlRequest: URLRequest,
        endpoint: HTTPEndpoint
    ) throws -> HTTPResponse<Body> {
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
    
    func handleError(_ error: HTTPError) -> HTTPError {
        errorHandler?.call(error)
        return error
    }
}

final class HTTPSessionDelegate: NSObject, URLSessionDelegate {
    private let state: HTTPSessionState
    private let configuration: HTTPCodableConfiguration

    init(state: HTTPSessionState, configuration: HTTPCodableConfiguration) {
        self.state = state
        self.configuration = configuration
    }
}

struct HTTPSessionState: Sendable {
    let ongoingRequests: [URL: URLSessionTask] = [:]
}

struct HTTPEndpoint {
    let url: URL
}

struct HTTPCodableConfiguration {
    let sessionConfiguration: URLSessionConfiguration
}

protocol HTTPRequestAdditional: Sendable {}

typealias HTTPDecoder<Body> = (HTTPDataResponse) throws -> HTTPResponse<Body>

struct HTTPDataResponse: Sendable {
    let endpoint: HTTPEndpoint
    let response: URLResponse
    let data: Data
    
    typealias Validator = @Sendable (HTTPDataResponse) -> Error?
    static let defaultValidator: Validator = { _ in return nil }
}


struct HTTPResponse<Body> {
    let body: Body
    
    func replaceDecodingTime(start: DispatchTime, end: DispatchTime) -> HTTPResponse {
        return self
    }
}

final class HTTPErrorHandlerActor: Sendable {
    func call(_ error: HTTPError) {}
}

enum HTTPError: Error {
    case perform(HTTPEndpoint, error: Error)
    case network(HTTPEndpoint, error: Error)
    case backend(HTTPDataResponse, error: Error)
    case decoding(HTTPDataResponse, error: Error)
}

class HTTPErrorHandler {
    func handle(_ error: HTTPError) {
        print("HTTP Error Occurred: \(error)")
    }
}

protocol HTTPRequest {
    var endpoint: HTTPEndpoint { get }
    var method: String { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    func convertToURLRequest(configuration: HTTPCodableConfiguration, additional: HTTPRequestAdditional?) throws -> URLRequest
}
