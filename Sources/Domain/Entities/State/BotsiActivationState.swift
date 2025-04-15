//
//  BotsiLifecycle.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import Foundation

actor BotsiLifecycle {
    
    enum State {
        case notInitialized
        case initializing(Task<Botsi, Error>)
        case initialized(Botsi)
    }
    
    private var state: State = .notInitialized
    
    var isInitialized: Bool {
        if case .initialized = state {
            return true
        }
        return false
    }
    
    @discardableResult
    func initializeIfNeeded(using factory: @Sendable @escaping () async throws -> Botsi) async throws -> Botsi {
        switch state {
        case .initialized(let sdk):
            return sdk
        case .initializing(let task):
            return try await task.value
        case .notInitialized:
            let task = Task { try await factory() }
            state = .initializing(task)
            
            do {
                let sdk = try await task.value
                state = .initialized(sdk)
                return sdk
            } catch {
                state = .notInitialized
                throw error
            }
        }
    }
    
    func withInitializedSDK<T: Sendable>(
        operation: @Sendable (Botsi) async throws -> T
    ) async throws -> T {
        switch state {
        case .initialized(let sdk):
            return try await operation(sdk)
        case .initializing(let task):
            let sdk = try await task.value
            return try await operation(sdk)
        case .notInitialized:
            throw BotsiError.sdkNotActivated
        }
    }
}
