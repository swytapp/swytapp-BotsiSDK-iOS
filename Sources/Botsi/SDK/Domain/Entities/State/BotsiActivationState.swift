//
//  BotsiActivationState.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import Foundation

extension Botsi {
    
    typealias BotsiActivationTask = Task<Botsi, Never>
    
    public static var isActivated: Bool { shared != nil }

    private enum BotsiSharedState {
        case activated(Botsi)
        case activating(BotsiActivationTask)
    }

    private static var shared: BotsiSharedState?

    static func setActivatingSDK(_ task: BotsiActivationTask) {
        guard shared == nil else { return }
        shared = .activating(task)
    }

    static func setSharedSDK(_ sdk: Botsi) {
        shared = .activated(sdk)
    }

    static var activatedSDK: Botsi {
        get async throws {
            switch shared {
            case .some(.activated(let sdk)):
                return sdk
            case .some(.activating(let task)):
                return await task.value
            case nil:
                throw BotsiError.sdkNotActivated
            }
        }
    }

    static func withActivatedSDK<T: Sendable>(
        identifier: BotsiOperationIdentifier,
        function: StaticString = #function,
        operation: @BotsiActor @Sendable @escaping (Botsi) async throws -> T
    ) async throws -> T {
        do {
            let sdk = try await activatedSDK
            let result = try await operation(sdk)
            return result
        } catch {
            throw error
        }
    }
}
