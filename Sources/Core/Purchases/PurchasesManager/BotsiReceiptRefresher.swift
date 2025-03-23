//
//  BotsiReceiptRefresher.swift
//  Botsi
//
//  Created by Vladyslav on 15.03.2025.
//


import StoreKit

final class ReceiptRefreshHelper: NSObject {
    
    private var continuation: CheckedContinuation<Data, Error>?
    private var request: SKReceiptRefreshRequest?
    
    func refreshReceipt() async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let request = SKReceiptRefreshRequest()
            request.delegate = self
            request.start()
            
            self.request = request
        }
    }
    
    private func finishContinuation(result: Result<Data, Error>) {
        request = nil
        guard let continuation = continuation else { return }
        self.continuation = nil
        self.request?.cancel()
        
        switch result {
        case .success(let data):
            continuation.resume(returning: data)
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}

extension ReceiptRefreshHelper: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        guard
            let receiptURL = Bundle.main.appStoreReceiptURL,
            let receiptData = try? Data(contentsOf: receiptURL),
            !receiptData.isEmpty
        else {
            self.request = nil
            finishContinuation(result: .failure(ReceiptError.missingReceipt))
            return
        }
        
        self.request?.cancel()
        self.request = nil
        finishContinuation(result: .success(receiptData))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.request?.cancel()
        self.request = nil
        finishContinuation(result: .failure(error))
    }
}

enum ReceiptError: Error {
    case missingReceipt
}
