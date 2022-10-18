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

    public func register() -> ExtensionManifest {
        return .init(
            name: "Discord",
            displayName: "Discord",
            version: "1.0",
            minAEVersion: "1.0"
        )
    }

    public func respond(action: String, parameters: [String: Any]) -> Bool {
        print("respond(action: String, parameters: [String: Any])", action, parameters)

        if action == "didOpen" {
            if let workspace = parameters["workspace"] as? String,
               let file = parameters["file"] as? String {
                print("Setting discord status")
                setDiscordStatusTo(project: workspace, custom: file)
            }
        }

        return true
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
