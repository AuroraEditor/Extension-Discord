//
//  RPC.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

extension SwordRPC {
    /// Sends a handshake to begin RPC interaction.
    func handshake() throws {
        let response = AuthorizationRequest(version: 1, clientId: appId)
        try send(response, opcode: .handshake)
    }

    /// Emits a subscribe request for the given command type.
    /// https://discord.com/developers/docs/topics/rpc#subscribe
    /// - Parameter type: The event type to subscribe for.
    func subscribe(_ type: EventType) {
        let command = Command(cmd: .subscribe, evt: type)
        try? send(command)
    }

    /// Handles incoming events from Discord.
    /// - Parameter payload: JSON given over IPC.
    func handleEvent(_ payload: String) {
        var data = decode(payload)

        guard let evt = data["evt"] as? String,
              let event = EventType(rawValue: evt)
        else {
            // We'll treat this as a close.
            // ...hopefully.
            delegate?.rpcDidDisconnect(self, code: data["code"] as? Int, message: data["message"] as? String)
            return
        }

        data = data["data"] as! [String: Any]

        switch event {
        case .error:
            let code = data["code"] as! Int
            let message = data["message"] as! String
            delegate?.rpcDidReceiveError(self, code: code, message: message)

        case .join:
            let secret = data["secret"] as! String
            delegate?.rpcDidJoinGame(self, secret: secret)

        case .joinRequest:
            let user = data["user"] as! [String: String]

            // TODO: can we properly decode this without doing this manually?
            let joinRequest = PartialUser(
                avatar: user["avatar"]!,
                discriminator: user["discriminator"]!,
                userId: user["id"]!,
                username: user["username"]!
            )

            let secret = data["secret"] as! String
            delegate?.rpcDidReceiveJoinRequest(self, user: joinRequest, secret: secret)

        case .ready:
            delegate?.rpcDidConnect(self)
            startPresenceUpdater()

        case .spectate:
            let secret = data["secret"] as! String
            delegate?.rpcDidSpectateGame(self, secret: secret)
        }
    }
}
