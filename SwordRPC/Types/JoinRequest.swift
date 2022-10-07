//
//  JoinRequest.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Used to represent a partial user given by Discord.
/// For example: https://discord.com/developers/docs/topics/rpc#activityjoinrequest-example-activity-join-request-dispatch-payload
public struct PartialUser: Decodable {
    let avatar: String
    let discriminator: String
    let userId: String
    let username: String

    enum CodingKeys: String, CodingKey {
        case avatar
        case discriminator
        case userId = "id"
        case username
    }
}
