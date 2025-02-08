//
//  BotsiUIError.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Foundation
import Botsi

public enum BotsiUIError: Error {
    case platformNotSupported
    
    case botsiNotActivated
    case botsiUINotActivated
    case activateOnce
    
    case encoding(Error)
    case unsupportedTemplate(String)
    case styleNotFound(String)
    case componentNotFound(String)
    case wrongComponentType(String)
    case rendering(Error)
}

extension BotsiUIError {
    static var activateOnceError: BotsiError { BotsiError(BotsiUIError.activateOnce) }
    static var botsiNotActivatedError: BotsiError { BotsiError(BotsiUIError.botsiNotActivated) }
}
