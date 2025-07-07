//
//  BotsiPaywallEventBus.swift
//  Botsi
//
//  Created by Kostiantyn Antoniuk on 17.06.2025.
//


@globalActor
actor BotsiPaywallEventBus {
    
    static let shared = BotsiPaywallEventBus()
    
    nonisolated var stream: AsyncStream<Event> { _stream.stream }
    
    private let _stream = AsyncStream<Event>.makeStream()
    private var selectedProduct: String?
    
    func send(_ event: Event) {
        _stream.continuation.yield(event)
        if case .productSelected(let id) = event { selectedProduct = id }
    }
    
    enum Event: Sendable {
        case opened, closed
        case productSelected(String)
        case restoreTapped
        case purchaseTapped
    }
}
