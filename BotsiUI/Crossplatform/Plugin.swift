//
//  Plugin.swift
//  Botsi
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Botsi
import Foundation

#if canImport(UIKit)
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension UIViewController {
    var isOrContainsBotsiController: Bool {
        guard let presentedViewController = presentedViewController else {
            return self is BotsiPaywallController
        }
        return presentedViewController is BotsiPaywallController
    }
}

#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension BotsiUI {
    @MainActor
    class Plugin {
#if canImport(UIKit)
        
        private static var paywallControllers = [UUID: BotsiPaywallController]()
        
        private static func cachePaywallController(_ controller: BotsiPaywallController, id: UUID) {
            paywallControllers[id] = controller
        }
        
        private static func deleteCachedPaywallController(_ id: String) {
            guard let uuid = UUID(uuidString: id) else { return }
            paywallControllers.removeValue(forKey: uuid)
        }
        
        private static func cachedPaywallController(_ id: String) -> BotsiPaywallController? {
            guard let uuid = UUID(uuidString: id) else { return nil }
            return paywallControllers[uuid]
        }
#endif
        
        package static func createView(
            paywall: BotsiPaywall,
            loadTimeout: TimeInterval?,
            preloadProducts: Bool,
            tagResolver: BotsiTagResolver?,
            timerResolver: BotsiTimerResolver?
        ) async throws -> BotsiUI.View {
#if canImport(UIKit)
            let products: [BotsiPaywallProduct]?
            
            if preloadProducts {
                products = try await Botsi.getPaywallProducts(paywall: paywall)
            } else {
                products = nil
            }
            
            let configuration = try await BotsiUI.getPaywallConfiguration(
                forPaywall: paywall,
                loadTimeout: loadTimeout,
                products: products,
                observerModeResolver: nil,
                tagResolver: tagResolver,
                timerResolver: timerResolver
            )
            
            let vc = try BotsiUI.paywallControllerWithUniversalDelegate(configuration)
            cachePaywallController(vc, id: vc.id)
            return vc.toBotsiUIView()
#else
            throw BotsiUIError.platformNotSupported
#endif
        }

        package static func presentView(
            viewId: String
        ) async throws {
#if canImport(UIKit)
            guard let vc = cachedPaywallController(viewId) else {
                throw BotsiError(BotsiUI.PluginError.viewNotFound(viewId))
            }
            
            guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
                throw BotsiError(BotsiUI.PluginError.viewPresentationError(viewId))
            }
            
            guard !rootVC.isOrContainsBotsiController else {
                throw BotsiError(BotsiUI.PluginError.viewAlreadyPresented(viewId))
            }
            
            vc.modalPresentationCapturesStatusBarAppearance = true
            vc.modalPresentationStyle = .overFullScreen
            
            await withCheckedContinuation { continuation in
                rootVC.present(vc, animated: true) {
                    continuation.resume()
                }
            }
#else
            throw BotsiUIError.platformNotSupported
#endif
        }
        
        package static func dismissView(
            viewId: String,
            destroy: Bool
        ) async throws {
#if canImport(UIKit)
            guard let vc = cachedPaywallController(viewId) else {
                throw BotsiError(BotsiUI.PluginError.viewNotFound(viewId))
            }

            await withCheckedContinuation { continuation in
                vc.dismiss(animated: true) {
                    if destroy {
                        deleteCachedPaywallController(viewId)
                    }
                    continuation.resume()
                }
            }
#else
            throw BotsiUIError.platformNotSupported
#endif
        }
        
        package static func showDialog(
            viewId: String,
            configuration: BotsiUI.DialogConfiguration
        ) async throws -> DialogActionType {
#if canImport(UIKit)
            guard let vc = cachedPaywallController(viewId) else {
                throw BotsiError(BotsiUI.PluginError.viewNotFound(viewId))
            }
            
            return await withCheckedContinuation { continuation in
                vc.showDialog(
                    configuration,
                    defaultActionHandler: {
                        continuation.resume(with: .success(.primary))
                    }, secondaryActionHandler: {
                        continuation.resume(with: .success(.secondary))
                    }
                )
            }
#else
            throw BotsiUIError.platformNotSupported
#endif
        }
    }
    
    enum DialogActionType {
        case primary
        case secondary
    }
}
