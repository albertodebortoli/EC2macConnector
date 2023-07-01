//  SSHClient.swift

import Foundation

final class SSHClient: Connecting {
    
    private enum SSHClientError: Error {
        case missingFile(String)
    }
    
    private let fileManager = FileManager.default
    
    private var directories: Directories { Directories(fileManager: fileManager) }
    
    private let shellClient = ShellClient()
    
    private let region: String
    
    init(region: String) {
        self.region = region
    }
    
    func connectToInstance(fleetIndex: Int) throws {
        let filename = "connect_\(fleetIndex).sh"
        let script = directories.scriptsDirectory(region: region)
            .appending(component: filename, directoryHint: .notDirectory)
        if !fileManager.fileExists(atPath: script.path) {
            throw SSHClientError.missingFile(script.path)
        }
        try shellClient.runShell("sh \(script.path)")
    }
    
    func connectToAllInstances() throws {
        let scriptsDirectory = directories.scriptsDirectory(region: region)
        let scripts = try fileManager.contentsOfDirectory(at: scriptsDirectory, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasSuffix(".sh") }
        for script in scripts {
            try shellClient.runShell("sh \(script.path)")
        }
    }
}
