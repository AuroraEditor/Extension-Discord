//
//  Requests.swift
//
//
//  Created by Spotlight Deveaux on 2022-01-17.
//

import Foundation

/// Describes the format needed for an authorization request.
/// https://discord.com/developers/docs/topics/rpc#authenticating-rpc-authorize-example
struct AuthorizationRequest: Encodable {
    let version: Int
    let clientId: String

    enum CodingKeys: String, CodingKey {
        case version = "v"
        case clientId = "client_id"
    }
}

/// RequestArg permits a union-like type for arguments to encode.
enum RequestArg: Encodable {
    /// An integer value.
    case int(Int)
    /// A string value.
    case string(String)
    /// An activity value.
    case activity(RichPresence)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .int(int):
            try container.encode(int)
        case let .string(string):
            try container.encode(string)
        case let .activity(presence):
            try container.encode(presence)
        }
    }
}

/// A generic format for a payload with a command, possibly used for an event.
struct Command: Encodable {
    /// The type of command to issue to Discord. For normal events, this should be .dispatch.
    let cmd: CommandType
    /// The nonce for this command. It should typically be an automatically generated UUID.
    let nonce: String = UUID().uuidString
    /// Arguments sent alongside the command.
    var args: [String: RequestArg]?
    /// The event type this command pertains to, if needed.
    var evt: EventType?
}

/// A generic format for sending an event.
struct Event: Encodable {
    /// The event type to handle.
    let eventType: EventType
    /// Arguments sent alongside the event.
    var args: [String: RequestArg]?

    /// Convenience initializer to create an event with the given type.
    init(_ event: EventType) {
        eventType = event
    }

    /// Convenience initializer to create an event with the given type and arguments.
    init(_ event: EventType, args: [String: RequestArg]?) {
        eventType = event
        self.args = args
    }

    func encode(to encoder: Encoder) throws {
        // All events are dispatched.
        var command = Command(cmd: .dispatch, args: args)
        command.evt = eventType

        try command.encode(to: encoder)
    }
}
