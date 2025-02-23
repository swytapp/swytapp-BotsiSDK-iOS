//
//  BotsiEnvironment.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//

import Foundation
import StoreKit

@BotsiActor
final class BotsiEnvironment: Sendable {
    let storeCountry: String
    let botsiSdkVersion: String
    let advertisingId: String
    let androidId: String // TODO: change to ios-related
    let appBuild: String
    let androidAppSetId: String // TODO: change to ios-related
    let appVersion: String
    let device: String
    let deviceId: String
    let locale: String
    let os: String
    let platform: String
    let timezone: String
    
    init() async throws {
        self.storeCountry = try await StorefrontManager().getStorefront().countryCode
        self.botsiSdkVersion = Botsi.sdkVersion
        self.advertisingId = UUID().uuidString
        self.androidId = UUID().uuidString
        self.appBuild = Application.build ?? "build undefined"
        self.androidAppSetId = UUID().uuidString
        self.appVersion = Application.version ?? "version undefined"
        self.device = Device.name
        self.deviceId = await Device.getIdentifierForVendor()
        self.locale = SystemLocaleProvider().getUserLocale().languageCode
        self.os = await BotsiSystemInfo.versionInfo
        self.platform = await BotsiSystemInfo.systemName.lowercased()
        self.timezone = TimeZone.current.identifier
    }
}

// MARK: - Storefront provider

/// `Base storefront data`
struct BotsiStorefront {
    let id: String
    let countryCode: String
}

/// `Define storefront provider`
protocol StorefrontProvider {
    func fetchStorefront() async throws -> BotsiStorefront
}

final class StoreKitSimulatorMockProvider: StorefrontProvider {
    func fetchStorefront() async throws -> BotsiStorefront {
        return .init(id: UUID().uuidString, countryCode: "en")
    }
}

/// `StoreKit 1 Provider Implementation`
final class StoreKit1Provider: StorefrontProvider {
    func fetchStorefront() async throws -> BotsiStorefront {
        guard let storefront = SKPaymentQueue.default().storefront else {
            throw StorefrontError.storefrontUnavailable
        }
        return BotsiStorefront(id: storefront.identifier, countryCode: storefront.countryCode)
    }
}

/// `StoreKit 2 Provider Implementation`
@available(iOS 15.0, macOS 12.0, *)
final class StoreKit2Provider: StorefrontProvider {
    func fetchStorefront() async throws -> BotsiStorefront {
        let storefront = await Storefront.current
        print("STOREFRONT: \(storefront)")
        return BotsiStorefront(id: storefront?.id ?? "unknown", countryCode: storefront?.countryCode ?? "default")
    }
}

/// `Determing StoreKit availability`
final class StorefrontManager {
    
    private let provider: StorefrontProvider
    
    init() {
        if #available(iOS 15.0,macOS 12.0, *) {
            if BotsiEnvironment.Device.isSimulator {
                self.provider = StoreKitSimulatorMockProvider()
            } else {
                self.provider = StoreKit2Provider()
            }
        } else {
            self.provider = StoreKit1Provider()
        }
    }
    
    /// `Fetch storefront data using the correct provider`
    func getStorefront() async throws -> BotsiStorefront {
        return try await provider.fetchStorefront()
    }
}

/// `Storefront provider Errors`
enum StorefrontError: Error {
    case storefrontUnavailable
    case unknownError
}


extension Botsi {
    public nonisolated static let sdkVersion = "1.0.0"
}

// MARK: - Device
extension BotsiEnvironment {
    enum Device {
        #if targetEnvironment(simulator)
            static let isSimulator = true
        #else
            static let isSimulator = false
        #endif

        static let name: String = {
            #if os(macOS) || targetEnvironment(macCatalyst)
                let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))

                var modelIdentifier: String?
                if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
                    modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
                }
                IOObjectRelease(service)

                if modelIdentifier?.isEmpty ?? false {
                    modelIdentifier = nil
                }

                return modelIdentifier ?? "unknown device"

            #else
                var systemInfo = utsname()
                uname(&systemInfo)
                let machineMirror = Mirror(reflecting: systemInfo.machine)
                return machineMirror.children.reduce("") { identifier, element in
                    guard let value = element.value as? Int8, value != 0 else { return identifier }
                    return identifier + String(UnicodeScalar(UInt8(value)))
                }
            #endif
        }()
        
        static func getIdentifierForVendor() async -> String {
            await MainActor.run {
                #if os(iOS) || os(tvOS) || os(visionOS)
                return UIDevice.current.identifierForVendor?.uuidString ?? "idfv undefined"
                #elseif os(watchOS)
                return WKInterfaceDevice.current().identifierForVendor?.uuidString ?? "idfv undefined"
                #else
                return "Unsupported OS"
                #endif
            }
        }
    }
}

// MARK: - System info

extension BotsiEnvironment {
    enum Application {
        static let version: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        static let build: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
}

@BotsiActor
struct BotsiSystemInfo {
    
    private static var `version`: String?
    
    static var versionInfo: String {
        get async {
            if let result = version { return result }

            #if os(macOS) || targetEnvironment(macCatalyst)
                let result = await MainActor.run { ProcessInfo().operatingSystemVersionString }
            #else
                let result = await UIDevice.current.systemVersion
            #endif

            version = result
            return result
        }
    }
    
    private static var `name`: String?

    static var systemName: String {
        get async {
            if let result = name { return result }

            #if os(macOS) || targetEnvironment(macCatalyst)
                let result = "macOS"
            #else
                let result = await UIDevice.current.systemName
            #endif

            name = result
            return result
        }
    }
}
