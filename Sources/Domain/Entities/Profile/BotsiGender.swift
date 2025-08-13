//
//  BotsiGender.swift
//  Botsi
//
//  Created by Vladyslav on 27.05.2025.
//

import Foundation

public enum BotsiGender: String, CaseIterable, Sendable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotSay = "preferNotSay"
} 