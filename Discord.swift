//
//  Discord.swift
//  DiscordExtension
//
//  Created by Wesley de Groot on 07/10/2022.
//

import Foundation
import AEExtensionKit

public class DiscordExtension: ExtensionInterface {
    let rpc = SwordRPC(appId: "1023938668349640734")
    var api: ExtensionAPI

    init(api: ExtensionAPI) {
        rpc.connect()
        self.api = api
        print("Hello from Discord EXT: \(api)!")
    }

    public func didOpen(workspace: String, file: String, contents: Data) {
        print("didOpen(workspace: String, file: String, contents: Data)", workspace, file)
        setDiscordStatusTo(project: workspace, custom: file)
    }

    func setDiscordStatusTo(project: String, custom: String) {
        rpc.clearPresence()

        let pURL = NSURL(string: project)?.lastPathComponent
        let cURL = NSURL(string: custom)?.lastPathComponent

        let fileIcon = NSURL(string: custom)?.pathExtension ?? "Unknown"

        var presence = RichPresence()
            // Large (AE) Icon
            presence.assets.largeImage = "auroraeditor"
            presence.assets.largeText = "AuroraEditor"

            // Small (File) icon
            presence.assets.smallImage = fileIcon.lowercased()
            presence.assets.smallText = "\(fileIcon.uppercased()) File"

            // Project name
            presence.details = pURL ?? project

            // File name
            presence.state = cURL ?? custom

        rpc.setPresence(presence)
    }
}

@objc(DiscordExtensionBuilder)
public class DiscordExtensionBuilder: ExtensionBuilder {
    public override func build(withAPI api: ExtensionAPI) -> ExtensionInterface {
        return DiscordExtension(api: api)
    }
}
