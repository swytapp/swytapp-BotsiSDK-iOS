//
//  BotsiSyncedTransactionStore.swift
//  Botsi
//
//  Created by Vladyslav on 15.03.2025.
//

import Foundation

public actor BotsiSyncedTransactionStore {
    
    private let transactionKey = UserDefaultKeys.User.lastSyncedTransactionId
    private let storage = BotsiStorageManager()
    
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
            BotsiLog.error("Failed to encode last synced transaction.")
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
