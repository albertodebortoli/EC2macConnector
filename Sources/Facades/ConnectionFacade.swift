//  ConnectionFacade.swift

import Foundation

final class ConnectionFacade {
    
    private enum ConnectionFacadeError: Error {
        case connectorNotConfigured
    }
    
    private let sshClient: Connecting
    private let vncClient: Connecting
    
    private let fileManager = FileManager.default
    
    private var directories: Directories { Directories(fileManager: fileManager) }
    
    private var isConfigured: Bool {
        fileManager.fileExists(atPath: directories.ec2macConnectorDirectory.path)
    }
    
    init(region: String) throws {
        sshClient = SSHClient(region: region)
        vncClient = VNCClient(region: region)
        try checkIfConfigured()
    }
    
    func connectSSH(to index: Int) throws {
        try sshClient.connectToInstance(fleetIndex: index)
    }
    
    func connectSSHAll() throws {
        try sshClient.connectToAllInstances()
    }
    
    func connectVNC(to index: Int) throws {
        try vncClient.connectToInstance(fleetIndex: index)
    }
    
    func connectVNCAll() throws {
        try vncClient.connectToAllInstances()
    }
    
    private func checkIfConfigured() throws {
        if !isConfigured {
            throw ConnectionFacadeError.connectorNotConfigured
        }
    }
}
