//
//  BotsiPaywallDelegate.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 19.06.2025.
//

import Foundation

public protocol BotsiPaywallDelegate: AnyObject {
    func botsiPaywallDidOpen()
    func botsiPaywallDidClose()
    func botsiPaywallDidTapPurchase(_ productId: String?)
    func botsiPaywallDidTapRestore()
    func botsiPaywallDidTapLogin()
    func botsiPaywallDidTapCustom(id: String)
    func botsiPaywallDidOpenURL(_ url: URL)
    func botsiPaywallDidEndTimer(id: String?)
}
