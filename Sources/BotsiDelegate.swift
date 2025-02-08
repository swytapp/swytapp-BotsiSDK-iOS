//
//  BotsiDelegate.swift
//  BotsiSDK
//
//  Created by Andrey Kyashkin on 28.10.2019.
//

import Foundation

public protocol BotsiDelegate: AnyObject, Sendable {
    /// Implement this delegate method to receive automatic profile updates
    func didLoadLatestProfile(_ profile: BotsiProfile)

    /// Implement this delegate method to handle a [user initiated an in-app purchases](https://developer.apple.com/documentation/storekit/skpaymenttransactionobserver/2877502-paymentqueue) from the App Store.
    /// The default implementation returns `true`.
    ///
    /// Return `true` to continue the transaction in your app.
    /// Return `false` to defer or cancel the transaction.
    ///
    /// If you return `false`, you can continue the transaction later by manually calling the `defermentCompletion`.
    func shouldAddStorePayment(for product: BotsiDeferredProduct) -> Bool
}

extension BotsiDelegate {
    public func shouldAddStorePayment(for _: BotsiDeferredProduct) -> Bool { true }
}

extension Botsi {
    #if compiler(>=5.10)
        /// Set the delegate to listen for `BotsiProfile` updates and user initiated an in-app purchases
        public nonisolated(unsafe) static var delegate: BotsiDelegate?
    #else
        /// Set the delegate to listen for `BotsiProfile` updates and user initiated an in-app purchases
        public nonisolated static var delegate: BotsiDelegate? {
            get { _nonisolatedUnsafe.delegate }
            set { _nonisolatedUnsafe.delegate = newValue }
        }

        private final class NonisolatedUnsafe: @unchecked Sendable {
            weak var delegate: BotsiDelegate?
        }

        private nonisolated static let _nonisolatedUnsafe = NonisolatedUnsafe()
    #endif

    static func callDelegate(_ call: @Sendable @escaping (BotsiDelegate) -> Void) {
        guard let delegate = Botsi.delegate else { return }
        let queue = BotsiConfiguration.callbackDispatchQueue ?? .main
        queue.async {
            call(delegate)
        }
    }
}
