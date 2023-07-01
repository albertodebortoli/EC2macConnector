//  ConnectionFilesClient.swift

import Foundation

final class ConnectionFilesClient {

    private enum ConnectionFilesClientError: Error {
        case failToSaveFile(String)
    }

    private let fileManager = FileManager.default

    private var directories: Directories { Directories(fileManager: fileManager) }

    private let region: String

    init(region: String) {
        self.region = region
    }

    func saveConnectionFiles(connectionsInfo: [ConnectionInfo]) throws -> [URL] {
        try connectionsInfo.map { connectionInfo in
            let ec2user = "ec2-user"
            let localPort = 5900 + connectionInfo.instance.fleetIndex
            let osaScriptLocation = try saveOsaScript(connectionInfo: connectionInfo, user: ec2user, localPort: localPort)
            let vnclocLocation = try saveVncloc(connectionInfo: connectionInfo, user: ec2user, localPort: localPort)
            return [osaScriptLocation, vnclocLocation]
        }.flatMap { $0 }
    }

    private func saveOsaScript(connectionInfo: ConnectionInfo, user: String, localPort: Int) throws -> URL {
        let scriptsDirectory = directories.scriptsDirectory(region: region)
        if !fileManager.fileExists(atPath: scriptsDirectory.path) {
            try fileManager.createDirectory(at: scriptsDirectory, withIntermediateDirectories: true)
        }
        let content = """
    osascript -e 'tell app "Terminal"
        do script "ssh -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -L \(localPort):localhost:5900 -i ~/.ssh/\(connectionInfo.privateKey.privateKeyFilename) \(user)@\(connectionInfo.instance.ip)"
    end tell'
    """
        let filename = "connect_\(connectionInfo.instance.fleetIndex).sh"
        let fileUrl = scriptsDirectory
            .appending(component: filename, directoryHint: .notDirectory)
        if fileManager.createFile(atPath: fileUrl.path,
                                  contents: content.data(using: .utf8),
                                  attributes: [FileAttributeKey.posixPermissions : 0o770]) {
            return fileUrl
        }
        throw ConnectionFilesClientError.failToSaveFile(fileUrl.path)
    }

    private func saveVncloc(connectionInfo: ConnectionInfo, user: String, localPort: Int) throws -> URL {
        let vnclocsDirectory = directories.vnclocsDirectory(region: region)
        if !fileManager.fileExists(atPath: vnclocsDirectory.path) {
            try fileManager.createDirectory(at: vnclocsDirectory, withIntermediateDirectories: true)
        }
        let content = ["URL": "vnc://\(user)@localhost:\(localPort)"]
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(content)
        let filename = "connect_\(connectionInfo.instance.fleetIndex).vncloc"
        let fileUrl = vnclocsDirectory
            .appending(component: filename, directoryHint: .notDirectory)
        if fileManager.createFile(atPath: fileUrl.path,
                                  contents: data,
                                  attributes: [FileAttributeKey.posixPermissions : 0o640]) {
            return fileUrl
        }
        throw ConnectionFilesClientError.failToSaveFile(fileUrl.path)
    }
}
