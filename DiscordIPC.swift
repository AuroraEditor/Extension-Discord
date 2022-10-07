//
//  Discord.swift
//  DiscordExtension
//
//  Created by Wesley de Groot on 27/09/2022.
//

import Foundation
import Cocoa
import Network

class Discord {
    enum opcode: UInt32 {
        case handshake = 0
        case frame = 1
        case close = 2
        case ping = 3
        case pong = 4
    }

    var appID: String
    private var connection: NWConnection?
    private let endpoint: String = NSTemporaryDirectory() + "discord-ipc-0"

    init(appID: String) {
        self.appID = appID
    }

    func connect() {
        print("Connecting to \(endpoint)")

        connection = NWConnection(
            to: NWEndpoint.unix(path: endpoint),
            using: .tcp
        )

        connection?.stateUpdateHandler = { state in
            switch state {
            case .setup:
                print("Setting up...")
            case .preparing:
                print("Prepairing...")
            case .waiting(let error):
                print("Waiting: \(error)")
            case .ready:
                print("Ready...")
            case .failed(let error):
                print("Failed: \(error)")
            case .cancelled:
                print("Cancelled :'(")
            default:
                break
            }
        }

        connection?.receiveMessage { completeContent, contentContext, isComplete, error in
            print(
                String(data: completeContent ?? Data(), encoding: .utf8),
                error
            )
        }

        connection?.start(queue: .global())
    }

    func uint32encode(opcode: opcode, message string: String) -> Data {
        let payload = string.data(using: .utf8)!

        var buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 8 + payload.count, alignment: 0)

        defer { buffer.deallocate() }

        buffer.copyBytes(from: payload)
        buffer[8...] = buffer[..<payload.count]
        buffer.storeBytes(of: opcode.rawValue, as: UInt32.self)
        buffer.storeBytes(of: UInt32(payload.count), toByteOffset: 4, as: UInt32.self)

        let uIntData = Data(bytes: &buffer, count: 8 + payload.count)

        return uIntData
    }


    func encode(opcode: opcode, message string: String) -> Data {
        let jsondata = string.data(using: .utf8)!

        var data = Data()
        data.append(UInt8(opcode.rawValue))
        data.append(UInt8(jsondata.count))
        data.append(contentsOf: [UInt8](jsondata))

        /*
         uint32 opcode (0 or 1)
         uint32 length (length)
         byte[length] jsonData (??)
         */
        return data
    }

    func handshake() {
        connect()

        // We should say "hello", with opcode handshake
        let hello = encode(opcode: .handshake, message: "{\"v\":1,\"client_id\":\"\(appID)\"}")

        print("Sending \(String.init(data: hello, encoding: .utf8))")
        connection?.send(
            content: hello,
            completion: .contentProcessed({ error in
                print("Error:", error?.localizedDescription)
            })
        )
    }

    func handshakev2() {
        connect()

        // We should say "hello", with opcode handshake
        let hello = uint32encode(opcode: .handshake, message: "{\"v\":1,\"client_id\":\"\(appID)\"}")

        print("Sending (V2) \(String.init(data: hello, encoding: .utf8))")
        connection?.send(
            content: hello,
            completion: .contentProcessed({ error in
                print("Error (V2):", error?.localizedDescription)
            })
        )
    }

    func setPresence(details: String, state: String, image: String) {

    }

}
