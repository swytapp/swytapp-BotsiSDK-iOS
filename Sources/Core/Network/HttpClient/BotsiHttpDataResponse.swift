//
//  BotsiHttpDataResponse.swift
//  Botsi
//
//  Created by Vladyslav on 22.02.2025.
//

import Foundation

struct BotsiHTTPDataResponse: Sendable {
    let endpoint: BotsiHTTPRequestPath
    let response: URLResponse
    let data: Data
    
    typealias Validator = @Sendable (BotsiHTTPDataResponse) -> Error?
    static let defaultValidator: Validator = { _ in return nil }
}
