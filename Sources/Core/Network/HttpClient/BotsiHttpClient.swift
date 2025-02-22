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
    
    private let session: BotsiHTTPSession
    
    struct URLConstants {
        static let backendHost: URL = URL(string: "https://swytapp-test.com.ua")!
    }
    
    init(with configuration: BotsiConfiguration) {
        let config = HTTPCodableConfiguration(sessionConfiguration: .default)
        let errorHandler = HTTPErrorHandler()
        let session = BotsiHTTPSession(configuration: config, errorHandler: errorHandler)
        self.session = session
    }
    
    func createUserProfile() async {
        do {
            let uuid = UUID().uuidString
            var request = CreateProfileRequest(uuid: uuid)
            request.headers = [
                "Authorization": "pk_O50YzT5HvlY1fSOP.6en44PYDcnIK2HOzIJi9FUYIE",
                "Content-type": "application/json"
            ]
            print("url: \(request.relativePath) ")
            let response: BotsiHTTPResponse<Data> = try await session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })
            
            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let createProfileResult: CreateProfileResponse = try wrapper.decode()
            // TODO: Store response into Profile Storage
            print("Response json: \(createProfileResult)")

        } catch {
            print("Request failed with error: \(error)")
        }
    }
}

struct CreateProfileRequest: BotsiHTTPRequest {
    static let serverHostURL: URL = BotsiHttpClient.URLConstants.backendHost
    
    var endpoint: BotsiHTTPRequestPath = .init(identifier: .createProfile)
    
    var method: BotsiHTTPMethod = .post
    
    var headers: [String: String] = [:]
    
    var body: Data? = nil
    
    private let uuid: String
    
    init(uuid: String) {
        self.uuid = uuid
    }
    
    func convertToURLRequest(configuration: HTTPCodableConfiguration, additional: (any HTTPRequestAdditional)?) throws -> URLRequest {

        guard let url = url() else {
            throw BotsiError.networkError("Unable to build url request")
        }
        
        var urlComponents = URLComponents(string: url.absoluteString)
        urlComponents?.path += "/\(uuid)"
        
        guard let finalUrl = urlComponents?.url else {
            throw BotsiError.networkError("Unable to build final url request")
        }
        
        var request = URLRequest(url: finalUrl)
        
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}


// MARK: - HTTP Session logic

@globalActor
actor BotsiHTTPSessionActor {
    static let shared = BotsiHTTPSessionActor()
    private var state = HTTPSessionState()

    func addRequest(_ url: URL, task: URLSessionTask) {
        state.ongoingRequests[url] = task
    }

    func removeRequest(_ url: URL) {
        state.ongoingRequests.removeValue(forKey: url)
    }

    func getOngoingRequests() -> [URL: URLSessionTask] {
        return state.ongoingRequests
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
    var ongoingRequests: [URL: URLSessionTask] = [:]
}


struct HTTPCodableConfiguration {
    let sessionConfiguration: URLSessionConfiguration
}

protocol HTTPRequestAdditional: Sendable {}


final class HTTPErrorHandlerActor: Sendable {
    func call(_ error: BotsiHTTPError) {}
}
