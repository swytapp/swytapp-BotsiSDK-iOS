//
//  EventsError.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

enum EventsError: Error {
    case sending(BotsiError.Source, error: Error)
    case encoding(BotsiError.Source, error: Error)
    case decoding(BotsiError.Source, error: Error)
    case interrupted(BotsiError.Source)
}

extension EventsError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .sending(source, error: error):
            "EventsError.sending(\(source), \(error))"
        case let .encoding(source, error: error):
            "EventsError.encoding(\(source), \(error))"
        case let .decoding(source, error: error):
            "EventsError.decoding(\(source), \(error))"
        case let .interrupted(source):
            "EventsError.interrupted(\(source))"
        }
    }
}

extension EventsError {
    var source: BotsiError.Source {
        switch self {
        case let .sending(src, _),
             let .encoding(src, _),
             let .decoding(src, _),
             let .interrupted(src): src
        }
    }

    var isInterrupted: Bool {
        switch self {
        case .interrupted: true
        case let .sending(_, error): (error as? HTTPError)?.isCancelled ?? false
        default: false
        }
    }

    var originalError: Error? {
        switch self {
        case let .sending(_, error): error
        case let .encoding(_, error),
             let .decoding(_, error): error
        default: nil
        }
    }
}

extension EventsError {
    static func sending(
        _ error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .sending(
            BotsiError.Source(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }

    static func encoding(
        _ error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .encoding(
            BotsiError.Source(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }

    static func decoding(
        _ error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .decoding(
            BotsiError.Source(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }

    static func interrupted(
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .interrupted(BotsiError.Source(
            file: file,
            function: function,
            line: line
        ))
    }
}
