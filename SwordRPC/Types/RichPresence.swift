//
//  RichPresence.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

public struct RichPresence: Encodable {
    public var assets = Assets()
    public var details = ""
    public var instance = true
    public var party = Party()
    public var secrets = Secrets()
    public var state = ""
    public var timestamps = Timestamps()

    public init() {}
}

public extension RichPresence {
    struct Timestamps: Encodable {
        public var end: Date?
        public var start: Date?

        enum CodingKeys: String, CodingKey {
            case end
            case start
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encodeIfPresent(start.map { Int($0.timeIntervalSince1970 * 1000) }, forKey: .start)
            try container.encodeIfPresent(end.map { Int($0.timeIntervalSince1970 * 1000) }, forKey: .end)
        }
    }

    struct Assets: Encodable {
        public var largeImage: String?
        public var largeText: String?
        public var smallImage: String?
        public var smallText: String?

        enum CodingKeys: String, CodingKey {
            case largeImage = "large_image"
            case largeText = "large_text"
            case smallImage = "small_image"
            case smallText = "small_text"
        }
    }

    struct Party: Encodable {
        public var id: String?
        public var max: Int?
        public var size: Int?

        enum CodingKeys: String, CodingKey {
            case id
            case size
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(id, forKey: .id)

            guard let max = self.max, let size = size else {
                return
            }

            try container.encode([size, max], forKey: .size)
        }
    }

    struct Secrets: Encodable {
        public var join: String?
        public var match: String?
        public var spectate: String?
    }
}
