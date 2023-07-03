//  ConfigurationFacade.swift

import Foundation

final class ConfigurationFacade {
    
    private let region: String
    
    private let verbose: Bool
    
    private let fileManager = FileManager.default
    
    private var directories: Directories { Directories(fileManager: fileManager) }
    
    private var isConfigured: Bool {
        fileManager.fileExists(atPath: directories.ec2macConnectorDirectory.path)
    }
    
    init(region: String, verbose: Bool) {
        self.region = region
        self.verbose = verbose
    }
    
    func configure(forceReconfiguration: Bool, secretsPrefix: String) async throws {
        if isConfigured {
            print("\(Constants.toolName) has already been configured.")
            if !forceReconfiguration {
                print("Do you want to reconfigure \(Constants.toolName)? yes/no")
                let reconfigureInput = readLine()
                if reconfigureInput != "yes", reconfigureInput != "y", reconfigureInput != "Y" {
                    print("Leaving configuration process.")
                    exit(0)
                }
            }
            print("Reconfiguring...")
        }
        else {
            print("Configuring...")
        }
        
        print("Retrieving EC2 instances information...")
        
        let instances = try await getInstances()
        if verbose {
            print("Retrieved \(instances.count) instances: \(String(reflecting: instances))")
        }
        
        print("Retrieving private keys...")
        
        let privateKeys = try await fetchPrivateKeys(for: instances, secretsPrefix: secretsPrefix)
        if verbose {
            print("Retrieved \(privateKeys.count) private keys: \(String(reflecting: privateKeys))")
        }
        
        print("Saving private keys...")
        
        let privateKeysUrls = try await savePrivateKeys(privateKeys)
        
        if verbose {
            print("Saved private keys at: \(privateKeysUrls.map{ $0.path })")
        }
        let connectionsInfo = ConnectionInfoFactory().makeConnectionsInfo(
            instances: instances,
            privateKeys: privateKeys)
        
        print("Configuring connection scripts and vncloc files...")
        
        let saveResult = try saveConnectScripts(connectionsInfo: connectionsInfo)
        if verbose {
            print("Saved connection scripts and vnclocs files at: \(saveResult.map{ $0.path })")
        }
        
        print("Configuration completed 🎉")
    }
    
    private func getInstances() async throws -> [Instance] {
        let client = EC2Client(region: region)
        return try await client.listRunningInstances()
    }
    
    private func fetchPrivateKeys(for instances: [Instance], secretsPrefix: String) async throws -> [PrivateKey] {
        let client = SecretsManagerClient(region: region)
        return try await instances.asyncCompactMap { instance in
            let prefix = try instance.correspondingKeyPairSecretIdPrefix(with: secretsPrefix)
            let secretEntry = try await client.retrieveFirstSecretWithPrefix(prefix)
            return PrivateKey(
                name: instance.keyPair,
                secretId: secretEntry.name,
                content: secretEntry.value,
                instanceId: instance.instanceId)
        }
    }
    
    private func savePrivateKeys(_ privateKeys: [PrivateKey]) async throws -> [URL] {
        let privateKeyClient = PrivateKeyClient()
        return try await privateKeyClient.savePrivateKeys(privateKeys)
    }
    
    private func saveConnectScripts(connectionsInfo: [ConnectionInfo]) throws -> [URL] {
        try ConnectionFilesClient(region: region).saveConnectionFiles(connectionsInfo: connectionsInfo)
    }
}
