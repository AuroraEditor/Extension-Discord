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
    var AuroraAPI: AuroraAPI = { _, _ in }

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

        if action == "registerCallback" {
            if let api = parameters["callback"] as? AuroraAPI {
                AuroraAPI = api
            }

            print("Idling...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("Idling... SET")
                self.setDiscordStatusTo(
                    project: "file://Aurora Editor",
                    custom: "file://idling"
                )
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
            // Large (File) icon
            presence.assets.largeImage = fileIcon.lowercased()
            presence.assets.largeText = "\(fileIcon.uppercased()) File"

            // Small (AE) Icon
            presence.assets.smallImage = "auroraeditor"
            presence.assets.smallText = "AuroraEditor"

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
