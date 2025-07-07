//
//  BotsiPaywallDelegate.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 19.06.2025.
//

public protocol BotsiPaywallDelegate: AnyObject {
    func botsiPaywallDidOpen()
    func botsiPaywallDidClose()
    func botsiPaywallDidTapPurchase(_ productId: String?)
    func botsiPaywallDidTapRestore()
}
