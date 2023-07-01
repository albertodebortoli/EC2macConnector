//  ConfigureCommand.swift

import ArgumentParser

struct ConfigureCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "configure",
        abstract: "Configure the tool by creating connect script and vncloc files for running EC2 mac instances."
    )
    
    @Option(name: .shortAndLong, help: "The AWS region.")
    private var region: String
    
    @Option(name: .shortAndLong, help: "The prefix used to store private keys in SecretsManager.")
    private var secretsPrefix: String
    
    @Flag(help: "Enable verbose mode.")
    private var verbose: Bool = false
    
    @Flag(name: .short, help: "Force reconfiguration.")
    private var forceReconfiguration: Bool = false
    
    func run() async throws {
        let facade = ConfigurationFacade(region: region, verbose: verbose)
        try await facade.configure(forceReconfiguration: forceReconfiguration, secretsPrefix: secretsPrefix)
    }
}
