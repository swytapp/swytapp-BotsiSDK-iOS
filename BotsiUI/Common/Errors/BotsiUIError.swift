//
//  BotsiUIError.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 20.06.2025.
//

public enum BotsiUIError: Error, Sendable {
    
    case contentParsingError

    public var localizedDescription: String {
        switch self {
        case .contentParsingError:
            return "UI Error: Failed to retrieve content"
        }
    }
}
