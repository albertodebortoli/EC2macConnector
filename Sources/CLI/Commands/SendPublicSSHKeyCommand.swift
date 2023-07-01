//  SendPublicSSHKeyCommand.swift

import ArgumentParser
import Foundation

struct SendPublicSSHKeyCommand: AsyncParsableCommand {
    
    private enum SendSSHPublicKeyCommandError: Error {
        case missingSSHPublicKeyFile
    }
    
    static let configuration = CommandConfiguration(
        commandName: "send-public-ssh-key",
        abstract: "Upload a public key to an EC2 instance to be used with EC2InstanceConnect."
    )
    
    @Option(name: .long, help: "The AWS region.")
    private var region: String
    
    @Option(name: .long, help: "The AWS availability zone.")
    private var availabilityZone: String
    
    @Option(name: .long, help: "The ID of the EC2 instance.")
    private var instanceId: String
    
    @Option(name: .long, help: "The path to the SSH public key.")
    private var sshPublicKeyFile: String
    
    mutating func validate() throws {
        let sshPublicKeyUrl = URL(fileURLWithPath: sshPublicKeyFile)
        guard FileManager.default.fileExists(atPath: sshPublicKeyUrl.path) else {
            throw SendSSHPublicKeyCommandError.missingSSHPublicKeyFile
        }
    }
    
    func run() async throws {
        try await sendPublicSSHKey()
    }
    
    @discardableResult
    private func sendPublicSSHKey() async throws -> Bool {
        let client = EC2InstanceConnectClient(region: region)
        let instanceOSUser = "ec2-user"
        let sshPublicKeyUrl = URL(fileURLWithPath: sshPublicKeyFile)
        let sshPublicKey = try String(contentsOf: sshPublicKeyUrl, encoding: .utf8)
        return try await client.sendPublicSSHKey(
            availabilityZone: availabilityZone,
            instanceId: instanceId,
            instanceOSUser: instanceOSUser,
            sshPublicKey: sshPublicKey)
    }
}

