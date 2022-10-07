//
//  IPCHandler.swift
//  SwiftRPC
//
//  Created by Spotlight Deveaux on 2022-01-17.
//

import Foundation
import NIOCore

enum IPCHandlingError: Error {
    case unknownOpcode
    case payloadTooShort
}

final class IPCInboundHandler: ByteToMessageDecoder {
    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = IPCPayload

    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        guard let opcodeInt = buffer.getInteger(at: 0, endianness: .little, as: UInt32.self) else {
            return .needMoreData
        }
        guard let opcode = IPCOpcode(rawValue: opcodeInt) else {
            throw IPCHandlingError.unknownOpcode
        }

        guard let size = buffer.getInteger(at: 4, endianness: .little, as: UInt32.self).map({ Int($0) }) else {
            return .needMoreData
        }

        if buffer.readableBytes - 8 < size {
            return .needMoreData
        }

        guard let payload = buffer.getString(at: 8, length: size) else {
            throw IPCHandlingError.payloadTooShort
        }

        let result = IPCPayload(opcode: opcode, payload: payload)
        context.fireChannelRead(self.wrapInboundOut(result))
        buffer.moveReaderIndex(to: 8 + size)
        return .needMoreData
    }
}

final class IPCOutboundHandler: ChannelOutboundHandler {
    typealias OutboundIn = IPCPayload
    public typealias OutboundOut = ByteBuffer

    public func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let data = unwrapOutboundIn(data)

        // Synthesize a buffer.
        var buffer = ByteBuffer()
        // Our payload's size is <payload length> + <opcode> + <size>.
        let payloadSize = data.payload.lengthOfBytes(using: .utf8)

        // Write contents.
        buffer.writeInteger(UInt32(data.opcode.rawValue), endianness: .little, as: UInt32.self)
        buffer.writeInteger(UInt32(payloadSize), endianness: .little, as: UInt32.self)
        buffer.writeString(data.payload)

        context.write(wrapOutboundOut(buffer), promise: promise)
    }
}
