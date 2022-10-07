//
//  Discord.swift
//  DiscordExtension
//
//  Created by Wesley de Groot on 07/10/2022.
//

import Foundation
import AEExtensionKit

public class DiscordExtension: ExtensionInterface {
    var api: ExtensionAPI

    init(api: ExtensionAPI) {
        self.api = api
        print("Hello from Discord EXT: \(api)!")
    }

    public func didOpen(workspace: String, file: String, contents: String) {
        setDiscordStatusTo(project: workspace, custom: file)
    }

    func setDiscordStatusTo(project: String, custom: String) {
        let rpc = SwordRPC(appId: "1023938668349640734")
        rpc.connect()

        var presence = RichPresence()
            presence.assets.largeImage = "auroraeditor"
            presence.details = project
            presence.state = custom

        rpc.setPresence(presence)
    }
}

@objc(DiscordExtension)
public class DiscordExtensionBuilder: ExtensionBuilder {
    public override func build(withAPI api: ExtensionAPI) -> ExtensionInterface {
        return DiscordExtension(api: api)
    }
}
