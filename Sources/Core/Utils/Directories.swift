//  Directories.swift

import Foundation

struct Directories {
    
    let fileManager: FileManager
    
    var ec2macConnectorDirectory: URL {
        fileManager.homeDirectoryForCurrentUser
            .appending(component: ".ec2macConnector", directoryHint: .isDirectory)
    }
    
    func scriptsDirectory(region: String) -> URL {
        ec2macConnectorDirectory
            .appending(component: region, directoryHint: .isDirectory)
            .appending(component: "scripts", directoryHint: .isDirectory)
    }
    
    func vnclocsDirectory(region: String) -> URL {
        ec2macConnectorDirectory
            .appending(component: region, directoryHint: .isDirectory)
            .appending(component: "vnclocs", directoryHint: .isDirectory)
    }
}
