//
//  IPCHandler.swift
//  SwiftNIO
//
//  Created by Spotlight Deveaux on 2022-01-17.
//

import Foundation

/// All observed IPC opcodes from Discord.
enum IPCOpcode: UInt32 {
    case handshake = 0
    case frame = 1
    case close = 2
    case ping = 3
    case pong = 4
}

/// A structure for the IPC payload.
struct IPCPayload {
    let opcode: IPCOpcode
    let payload: String
}
