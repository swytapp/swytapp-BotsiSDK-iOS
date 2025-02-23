//
//  BotsiHttpError.swift
//  Botsi
//
//  Created by Vladyslav on 22.02.2025.
//

enum BotsiHTTPError: Error {
    case perform(BotsiHTTPRequestPath, error: Error)
    case network(BotsiHTTPRequestPath, error: Error)
    case backend(BotsiHTTPDataResponse, error: Error)
    case decoding(BotsiHTTPDataResponse, error: Error)
}

class HTTPErrorHandler {
    func handle(_ error: BotsiHTTPError) {
        print("HTTP Error Occurred: \(error)")
    }
}
