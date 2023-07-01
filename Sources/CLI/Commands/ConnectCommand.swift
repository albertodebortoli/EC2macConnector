//  ConnectCommand.swift

import ArgumentParser

struct ConnectCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "connect",
        abstract: "Connect to EC2 mac instances over SSH or VNC."
    )

    @Option(name: .shortAndLong, help: "The AWS region.")
    private var region: String

    @Argument(help: "The index of the instance to connect to.")
    private var index: Int

    @Flag(help: "Use VNC session instead of SSH. Required an SSH session to run already.")
    private var vnc: Bool = false

    func run() async throws {
        if let facade = try? ConnectionFacade(region: region) {
            switch vnc {
            case false:
                try facade.connectSSH(to: index)
            case true:
                try facade.connectVNC(to: index)
            }
        } else {
            print("\(Constants.toolName) has not been configured. Configure it by running the `configure` command.")
        }
    }
}

