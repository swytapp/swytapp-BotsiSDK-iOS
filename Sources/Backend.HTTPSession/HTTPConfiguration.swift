//
//  HTTPConfiguration.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

protocol HTTPConfiguration: Sendable {
    var baseURL: URL { get }
    var sessionConfiguration: URLSessionConfiguration { get }
}

extension HTTPConfiguration {
    var sessionConfiguration: URLSessionConfiguration { .ephemeral }
}
