//
//  Presence.swift
//  SwordRPC
//
//  Created by Spotlight Deveaux on 3/26/22.
//

import Foundation

public extension SwordRPC {
    /// Sets the presence for this RPC connection.
    /// The presence is guaranteed to be set within 15 seconds of call
    /// in accordance with Discord ratelimits.
    ///
    /// If the presence is set before RPC is connected, it is discarded.
    ///
    /// - Parameter presence: The presence to display.
    func setPresence(_ presence: RichPresence) {
        self.currentPresence.send(presence)
    }

    func clearPresence() {
        self.currentPresence.send(nil)
    }

    /// Sends a command to clear the current presence.
    internal func sendEmptyPresence() {
        log.notice("Sending an empty presence.")

        // We send SET_ACTIVITY with no activity payload to clear our presence.
        let command = Command(cmd: .setActivity, args: [
            "pid": .int(Int(pid)),
        ])
        try? send(command)
    }

    /// Sends a command to set the current activity.
    internal func sendPresence(_ presence: RichPresence) throws {
        log.notice("Sending new presence now: \(String(describing: presence))")

        let command = Command(cmd: .setActivity, args: [
            "pid": .int(Int(self.pid)),
            "activity": .activity(presence),
        ])

        try self.send(command)
    }

    internal func startPresenceUpdater() {
        log.notice("Starting presence updater.")

        self.presenceUpdater = self.currentPresence.throttle(for: .seconds(3), scheduler: self.worker, latest: true ).sink { presence in
            if let presence = presence {
                try? self.sendPresence(presence)
            } else {
                self.sendEmptyPresence()
            }
        }
    }
}
