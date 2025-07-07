//
//  BotsiUI+Optional.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 27.06.2025.
//

import CoreGraphics

extension String {
    
    func toFloat() -> Float? {
        Float(self.trimmingCharacters(in: .whitespaces))
    }
    
    func toCGFloat() -> CGFloat {
        guard let float = self.toFloat() else { return 0 }
        return CGFloat(float)
    }
    
    func toCGFloat(default defaultValue: CGFloat) -> CGFloat {
        return Float(self).map { CGFloat($0) } ?? defaultValue
    }
}
