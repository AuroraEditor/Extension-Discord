//
//  ConnectionHandler.swift
//  SwordRPC
//
//  Created by Spotlight Deveaux on 2022-01-17.
//

import Foundation
import NIOCore

extension ConnectionClient {
    typealias InboundIn = IPCPayload
    typealias OutboundOut = IPCPayload

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = unwrapInboundIn(data)

        switch frame.opcode {
        case .ping:
            // We are expected to respond to all pings.
            ping(context: context, frame: frame)
        case .frame:
            receivedData(frame: frame)
        case .close:
            receivedClose(context: context, frame: frame)
        default:
            // Handle unknown frames as errors.
            closeOnError(context: context)
        }
    }

    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    private func receivedClose(context: ChannelHandlerContext, frame: IPCPayload) {
        // We should have recieved data from this close, as Discord provides us with such.
        let data = frame.payload

        // Close the connection, as requested.
        context.close(promise: nil)

        // Call back if possible.
        disconnectHandler?(data)
    }

    private func receivedData(frame: IPCPayload) {
        textHandler?(frame.payload)
    }

    private func ping(context: ChannelHandlerContext, frame: IPCPayload) {
        // Write back the given ping data for a pong.
        let data = frame.payload
        let frame = IPCPayload(opcode: .pong, payload: data)
        context.write(wrapOutboundOut(frame), promise: nil)
    }

    private func closeOnError(context: ChannelHandlerContext) {
        // We have hit an error, so we want to close.
        // We do that by sending a close frame and then shutting down the write side of the connection.
        // The server will respond with a close of its own.
        let frame = IPCPayload(opcode: .close, payload: "")
        context.write(wrapOutboundOut(frame)).whenComplete { (_: Result<Void, Error>) in
            context.close(mode: .output, promise: nil)
        }
    }

    /// Sends the given data for the given opcode to the connected WebSocket.
    func send(data: String, opcode: IPCOpcode) throws {
        let frame = IPCPayload(opcode: opcode, payload: data)
        try channel!.writeAndFlush(wrapOutboundOut(frame)).wait()
    }
}
