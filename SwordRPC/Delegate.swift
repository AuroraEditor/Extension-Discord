//
//  Delegate.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

public protocol SwordRPCDelegate: AnyObject {
    /// Called back when our RPC connects to Discord.
    /// - Parameter rpc: The current RPC to work with.
    func rpcDidConnect(
        _ rpc: SwordRPC
    )

    /// Called when Discord disconnects our RPC.
    /// - Parameters:
    ///   - rpc: The current RPC to work with.
    ///   - code: The disconnection code, if given by Discord.
    ///   - msg: The disconnection reason, if given by Discord.
    func rpcDidDisconnect(
        _ rpc: SwordRPC,
        code: Int?,
        message msg: String?
    )

    /// Called when the RPC receives an error from Discord.
    /// The connection will be terminated immediately.
    /// - Parameters:
    ///   - rpc: The current RPC to work with.
    ///   - code: The error code as provided by Discord.
    ///   - msg: The error message as provided by Discord.
    func rpcDidReceiveError(
        _ rpc: SwordRPC,
        code: Int,
        message msg: String
    )

    /// Called when Discord notifies us a user joined a game.
    /// - Parameters:
    ///   - rpc: The current RPC to work with.
    ///   - secret: The join secret for the invite.
    func rpcDidJoinGame(
        _ rpc: SwordRPC,
        secret: String
    )

    /// Called when Discord notifies us a client is spectating a game.
    /// - Parameters:
    ///   - rpc: The current RPC to work with.
    ///   - secret: The spectate secret for the invite.
    func rpcDidSpectateGame(
        _ rpc: SwordRPC,
        secret: String
    )

    /// Called when Discord notifies us the client received a join request.
    /// - Parameters:
    ///   - rpc: The current RPC to work with.
    ///   - user: The user requesting an invite.
    ///   - secret: The spectate secret for the request.
    func rpcDidReceiveJoinRequest(
        _ rpc: SwordRPC,
        user: PartialUser,
        secret: String
    )
}

/// A dummy extension providing empty, default functions for our protocol.
/// We do this to avoid using optional, as it forces our functions to be @objc.
public extension SwordRPCDelegate {
    func rpcDidConnect(_: SwordRPC) {}
    func rpcDidDisconnect(_: SwordRPC, code _: Int?, message _: String?) {}
    func rpcDidReceiveError(_: SwordRPC, code _: Int, message _: String) {}
    func rpcDidJoinGame(_: SwordRPC, secret _: String) {}
    func rpcDidSpectateGame(_: SwordRPC, secret _: String) {}
    func rpcDidReceiveJoinRequest(_: SwordRPC, user _: PartialUser, secret _: String) {}
}
