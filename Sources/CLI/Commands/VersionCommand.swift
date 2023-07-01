//  VersionCommand.swift

import ArgumentParser

struct VersionCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "version",
        abstract: "Output the current version of the tool."
    )

    func run() throws {
        print(Constants.version)
    }
}
