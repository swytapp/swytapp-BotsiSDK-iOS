//
//  BotsiTextStyleModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 21.06.2025.
//
import Foundation

@available(iOS 15.0, *)
public struct BotsiTextStyleModel: Codable, Sendable {
    public let font: BotsiFontModel?
    public let size: String?
    public let color: String
    public let opacity: Int?
}

@available(iOS 15.0, *)
public struct BotsiFontModel: Codable, Sendable {
    public let id: String?
    public let name: String?
    public let isSelected: Bool?
    public let types: [BotsiFontTypeModel]?
}

@available(iOS 15.0, *)
public struct BotsiFontTypeModel: Codable, Sendable {
    public let name: String?
    public let id: String?
    public let fontWeight: Int?
    public let fontStyle: String?
    public let isSelected: Bool?
}
