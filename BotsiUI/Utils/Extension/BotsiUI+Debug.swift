//
//  BotsiUI+Debug.swift
//  BotsiUI
//
//  Created by Vladyslav on 22.03.2025.
//

import Foundation

extension Data {
    func prettyPrintJSON() {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self)
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            print(String(data: prettyData, encoding: .utf8) ?? "Invalid JSON")
        } catch {
            print("JSON parsing error: \(error)")
        }
    }
}
