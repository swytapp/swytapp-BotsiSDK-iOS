//
//  BotsiHttpClient.swift
//  Botsi
//
//  Created by Vladyslav on 21.02.2025.
//

import Foundation

// MARK: - Backend
public struct BotsiHttpClient: Sendable {
    
    let sdkApiKey: String
    let session: BotsiHTTPSession
    
    struct URLConstants {
        static let backendHost: URL = URL(string: "https://swytapp-test.com.ua")!
    }
    
    init(with configuration: BotsiConfiguration, key: String) {
        let config = HTTPCodableConfiguration(sessionConfiguration: .default)
        let errorHandler = HTTPErrorHandler()
        let session = BotsiHTTPSession(configuration: config, errorHandler: errorHandler)
        self.session = session
        self.sdkApiKey = key
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
