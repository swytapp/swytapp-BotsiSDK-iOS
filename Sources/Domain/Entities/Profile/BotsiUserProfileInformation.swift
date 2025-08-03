//
//  BotsiProfileUpdate.swift
//  Botsi
//
//  Created by Vladyslav on 27.05.2025.
//

import Foundation

public struct BotsiUserProfileInformation: Sendable {
    public let birthday: Date?
    public let email: String?
    public let username: String?
    public let gender: BotsiGender?
    public let phone: String?
    internal let ip: String?
    
    public init(
        birthday: Date? = nil,
        email: String? = nil,
        username: String? = nil,
        gender: BotsiGender? = nil,
        phone: String? = nil,
        ip: String? = nil
    ) {
        self.birthday = birthday
        self.email = email
        self.username = username
        self.gender = gender
        self.phone = phone
        self.ip = ip
    }
} 
