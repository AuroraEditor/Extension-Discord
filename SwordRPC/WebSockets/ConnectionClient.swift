//
//  ConnectionClient.swift
//  SwordRPC
//
//  Created by Spotlight Deveaux on 2022-01-17.
//

import Foundation
import NIOCore
import NIOPosix

class ConnectionClient: ChannelInboundHandler {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    var channel: Channel?
    let pipePath: String

    /// Initializes a new socket client for the given pipe.
    init(pipe pipePath: String) {
        self.pipePath = pipePath
    }

    /// Called upon a disconnect.
    var disconnectHandler: ((_ text: String) -> Void)?
    /// Called upon a text event.
    var textHandler: ((_ text: String) -> Void)?

    /// Connects to the configured pipe socket.
    /// This call is intentionally blocking, in order to ensure connection
    /// success over a local UNIX socket.
    func connect() throws {
        let bootstrap = ClientBootstrap(group: group)
            // Enable SO_REUSEADDR.
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { channel in
                // We add our custom inbound/outbound coders.
                channel.pipeline.addHandlers([
                    ByteToMessageHandler(IPCInboundHandler()),
                    IPCOutboundHandler(),
                    self,
                ])
            }

        let future = bootstrap.connect(unixDomainSocketPath: pipePath)
        // We will willingly block connection, as this is to a local UNIX socket.
        let localChannel = try future.wait()

        channel = localChannel
    }

    func close() {
        try? group.syncShutdownGracefully()
    }
}
