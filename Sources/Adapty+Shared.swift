//
//  Botsi+withActivatedSDK.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 22.09.2024
//

import Foundation

private let log = Log.default

extension Botsi {
    public static var isActivated: Bool { shared != nil }

    private enum Shared {
        case activated(Botsi)
        case activating(Task<Botsi, Never>)
    }

    private static var shared: Shared?
    static func set(activatingSDK task: Task<Botsi, Never>) {
        if shared == nil { shared = .activating(task) }
    }

    static func set(shared sdk: Botsi) { shared = .activated(sdk) }

    package static var activatedSDK: Botsi {
        get async throws {
            switch shared {
            case let .some(.activated(sdk)):
                return sdk
            case let .some(.activating(task)):
                return await task.value
            default:
                throw BotsiError.notActivated()
            }
        }
    }

    static var optionalSDK: Botsi? { // TODO: Deprecated
        if case let .some(.activated(sdk)) = shared {
            sdk
        } else {
            nil
        }
    }

    static func withActivatedSDK<T: Sendable>(
        methodName: MethodName,
        logParams: EventParameters? = nil,
        function: StaticString = #function,
        operation: @BotsiActor @Sendable @escaping (Botsi) async throws -> T
    ) async throws -> T {
        let stamp = Log.stamp

        Botsi.trackSystemEvent(BotsiSDKMethodRequestParameters(methodName: methodName, stamp: stamp, params: logParams))
        log.verbose("Calling now: \(function) [\(stamp)]  \(methodName): \(logParams?.description ?? "nil")")

        do {
            let result = try await operation(Botsi.activatedSDK)
            Botsi.trackSystemEvent(BotsiSDKMethodResponseParameters(methodName: methodName, stamp: stamp))
            log.verbose("Completed \(function) [\(stamp)] is successful.")
            return result
        } catch {
            Botsi.trackSystemEvent(BotsiSDKMethodResponseParameters(methodName: methodName, stamp: stamp, error: String(describing: error)))
            log.error("Completed \(function) [\(stamp)] with error: \(error).")
            throw error
        }
    }

    static func withoutSDK<T: Sendable>(
        methodName: MethodName,
        logParams: EventParameters? = nil,
        function: StaticString = #function,
        operation: @BotsiActor @Sendable @escaping () async throws -> T
    ) async throws -> T {
        let stamp = Log.stamp

        Botsi.trackSystemEvent(BotsiSDKMethodRequestParameters(methodName: methodName, stamp: stamp, params: logParams))
        log.verbose("Calling now: \(function) [\(stamp)].  \(methodName): \(logParams?.description ?? "nil")")

        do {
            let result = try await operation()
            Botsi.trackSystemEvent(BotsiSDKMethodResponseParameters(methodName: methodName, stamp: stamp))
            log.verbose("Completed \(function) [\(stamp)] is successful.")
            return result
        } catch {
            Botsi.trackSystemEvent(BotsiSDKMethodResponseParameters(methodName: methodName, stamp: stamp, error: error.localizedDescription))
            log.error("Completed \(function) [\(stamp)] with error: \(error).")
            throw error
        }
    }
}
