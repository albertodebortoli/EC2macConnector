//  VNCClient.swift

import Foundation

final class VNCClient: Connecting {
    
    private enum VNCClientError: Error {
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
        let filename = "connect_\(fleetIndex).vncloc"
        let vncloc = directories.vnclocsDirectory(region: region)
            .appending(component: filename, directoryHint: .notDirectory)
        if !fileManager.fileExists(atPath: vncloc.path) {
            throw VNCClientError.missingFile(vncloc.path)
        }
        try shellClient.runShell("open \(vncloc.path)")
    }
    
    func connectToAllInstances() throws {
        let vnclocsDirectory = directories.vnclocsDirectory(region: region)
        let vnclocs = try fileManager.contentsOfDirectory(at: vnclocsDirectory, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasSuffix(".vncloc") }
        for vncloc in vnclocs {
            try shellClient.runShell("open \(vncloc.path)")
        }
    }
}
