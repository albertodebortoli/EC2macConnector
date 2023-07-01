//  PrivateKeyClient.swift

import Foundation

final class PrivateKeyClient {
    
    private enum PrivateKeyClientError: Error {
        case failToSaveFile(String)
    }
    
    private let fileManager = FileManager.default
    
    private var sshDirectory: URL {
        fileManager.homeDirectoryForCurrentUser
            .appending(component: ".ssh", directoryHint: .isDirectory)
    }
    
    @discardableResult
    func savePrivateKeys(_ privateKeys: [PrivateKey]) async throws -> [URL] {
        if !fileManager.fileExists(atPath: sshDirectory.path) {
            try fileManager.createDirectory(at: sshDirectory, withIntermediateDirectories: false)
        }
        return try privateKeys.compactMap { privateKey in
            let data = privateKey.content.data(using: .utf8)
            let sshKeyUrl = sshDirectory
                .appending(component: privateKey.privateKeyFilename, directoryHint: .notDirectory)
            if !fileManager.createFile(atPath: sshKeyUrl.path,
                                       contents: data,
                                       attributes: [FileAttributeKey.posixPermissions : 0o600]) {
                throw PrivateKeyClientError.failToSaveFile(sshKeyUrl.path)
            }
            return sshKeyUrl
        }
    }
}
