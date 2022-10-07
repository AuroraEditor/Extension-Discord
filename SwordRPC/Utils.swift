//
//  Utils.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

extension SwordRPC {
    /// Decodes the given string as a JSON object.
    func decode(_ json: String) -> [String: Any] {
        decode(json.data(using: .utf8)!)
    }

    /// Decodes the given data as a JSON object.
    func decode(_ json: Data) -> [String: Any] {
        do {
            return try JSONSerialization.jsonObject(with: json, options: []) as! [String: Any]
        } catch {
            return [:]
        }
    }

    /// Serializes and sends the given object as JSON.
    func send(_ response: Encodable) throws {
        try send(response, opcode: .frame)
    }

    /// Sends the given JSON string with the given opcode.
    func send(_ response: Encodable, opcode: IPCOpcode) throws {
        let data = try response.toJSON()
        try client?.send(data: data, opcode: opcode)
    }
}

extension Encodable {
    func toJSON() throws -> String {
        let result = try JSONEncoder().encode(self)
        return String(bytes: result, encoding: .utf8) ?? ""
    }
}
