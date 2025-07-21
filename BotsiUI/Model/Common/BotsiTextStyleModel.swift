//
//  BotsiTextStyleModel.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 21.06.2025.
//
import Foundation

@available(iOS 15.0, *)
public struct BotsiTextStyleModel: Decodable, Sendable {
    public let font: BotsiFontModel?
    public let size: String?
    public let align: BotsiAlign?
    public let color: BotsiFillColor
    public let opacity: Int?
}

@available(iOS 15.0, *)
public struct BotsiFontModel: Decodable, Sendable {
    public let id: String?
    public let name: String?
    public let isSelected: Bool?
    public let types: [BotsiFontTypeModel]?
}

@available(iOS 15.0, *)
public struct BotsiFontTypeModel: Decodable, Sendable {
    public let name: String?
    public let id: String?
    public let fontWeight: Int?
    public let fontStyle: String?
    public let isSelected: Bool?
}
