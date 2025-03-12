//
//  BotsiLifecycle.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import Foundation

/// `Actor that manages the shared Botsi lifecycle.`
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
    
    /// `Initializes the SDK`
    /// - Parameter factory: An async closure that creates a new `Botsi` instance.
    @discardableResult
    func initializeIfNeeded(using factory: @Sendable @escaping () async throws -> Botsi) async throws -> Botsi {
        switch state {
        case .initialized(let sdk):
            /// `Already initialized, just return sdk instance.`
            return sdk
            
        case .initializing(let task):
            /// `await the existing task`
            return try await task.value
            
        case .notInitialized:
            /// `We need to initialize. Create a Task to do the work.`
            let task = Task { try await factory() }
            state = .initializing(task)
            
            do {
                let sdk = try await task.value
                state = .initialized(sdk)
                return sdk
            } catch {
                /// `If initialization fails, revert to "notInitialized".`
                state = .notInitialized
                throw error
            }
        }
    }
    
    /// `Provides a fully initialized Botsi instance to "operation"`
    func withInitializedSDK<T: Sendable>( // Task<Botsi, Never>
        operation: @Sendable (Botsi) async throws -> T
    ) async throws -> T {
        switch state {
        case .initialized(let sdk):
            return try await operation(sdk)
        case .initializing(let task):
            // Wait for the initialization task to finish
            let sdk = try await task.value
            return try await operation(sdk)
        case .notInitialized:
            // If nobody has tried to initialize yet, we can’t proceed
            throw BotsiError.sdkNotActivated
        }
    }
}
