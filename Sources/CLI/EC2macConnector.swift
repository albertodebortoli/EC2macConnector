// EC2macConnector.swift

import ArgumentParser

@main
struct EC2macConnector: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "A tool to easily connect to EC2 mac instances.",
        subcommands: [
            ConfigureCommand.self,
            ConnectCommand.self,
            VersionCommand.self
        ])
}
