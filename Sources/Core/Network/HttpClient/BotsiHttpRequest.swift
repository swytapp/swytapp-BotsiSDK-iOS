//
//  BotsiHttpRequest.swift
//  Botsi
//
//  Created by Vladyslav on 22.02.2025.
//

import Foundation

protocol BotsiHTTPRequest {
    static var serverHostURL: URL { get }
    var endpoint: BotsiHTTPRequestPath { get }
    var method: BotsiHTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    
    
    func convertToURLRequest(configuration: HTTPCodableConfiguration, additional: HTTPRequestAdditional?) throws -> URLRequest
}

extension BotsiHTTPRequest {
    var relativePath: String {
        return "/api/v1/sdk/\(self.endpoint.identifier)"
    }

    var url: URL? { return self.url(proxyURL: nil) }

    func url(proxyURL: URL? = nil) -> URL? {
        return URL(string: self.relativePath, relativeTo: proxyURL ?? Self.serverHostURL)
    }
}
