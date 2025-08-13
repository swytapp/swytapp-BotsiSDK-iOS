//
//  BotsiIpAddressManager.swift
//  Botsi
//
//  Created by Vladyslav on 28.05.2025.
//

import Foundation

extension Botsi {
    
    @BotsiActor
    public class IPAddressManager {
        public private(set) static var currentIPAddress: String?
        private static var fetchStarted = false
        
        public static func startIPFetchingIfNeeded() {
            guard currentIPAddress == nil, !fetchStarted else { return }
            
            fetchStarted = true
            
            Task.detached(priority: .utility) {
                await performIPFetch()
            }
        }
        
        public static func fetchIPAddress() async throws -> String {
            let ip = try await fetchFromService()
            currentIPAddress = ip
            return ip
        }
        
        public static func getIPAddress() async throws -> String {
            if let cached = currentIPAddress {
                return cached
            }
            return try await fetchIPAddress()
        }
        
        public static func clearCache() {
            currentIPAddress = nil
            fetchStarted = false
        }
        
        private static func performIPFetch() async -> String? {
            do {
                let ip = try await fetchFromService()
                currentIPAddress = ip
                return ip
            } catch {
                return nil
            }
        }
        
        private static func fetchFromService() async throws -> String {
            let url = URL(string: "https://api.ipify.org?format=json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(IPAddressResponse.self, from: data)
            return response.ip
        }
    }
    
    private struct IPAddressResponse: Codable {
        let ip: String
    }
}
