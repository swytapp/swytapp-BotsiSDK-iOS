//
//  BotsiSyncedTransactionStore.swift
//  Botsi
//
//  Created by Vladyslav on 15.03.2025.
//

import Foundation

/// `Cached transaction logic for later use`
public actor BotsiSyncedTransactionStore {
    
    private let transactionKey = UserDefaultKeys.User.lastSyncedTransactionId
    private let storage = BotsiStorageManager()
    
    // cached transaction id
    private var cachedTransactionOriginalIdentifier: String?
    
    init() async {
        do {
            let transactionId = try await storage.retrieve(String.self, forKey: transactionKey)
            self.cachedTransactionOriginalIdentifier = transactionId
        } catch {
            self.cachedTransactionOriginalIdentifier = nil
        }
    }
    
    func saveLastSyncedTransaction(_ transactionId: String) async {
        do {
            try await storage.save(transactionId, forKey: transactionKey)
            cachedTransactionOriginalIdentifier = transactionId
        } catch {
            cachedTransactionOriginalIdentifier = nil
            print("Failed to encode last synced transaction: \(error)")
        }
    }
    
    func getLastSyncedTransactionIdentifier() -> String? {
        return cachedTransactionOriginalIdentifier
    }
    
    func clearLastSyncedTransaction() async {
        await storage.delete(forKey: transactionKey)
        cachedTransactionOriginalIdentifier = nil
    }
}
