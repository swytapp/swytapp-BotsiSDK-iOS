//
//  BotsiProductIDsMapper.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//

// MARK: - Response model
struct ProductIDsDtoResponse: Codable {
    let ok: Bool
    let data: [String] // array of identifiers
}
