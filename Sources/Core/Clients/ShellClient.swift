//  ShellClient.swift

import Foundation

enum ShellType: String {
    case sh = "/bin/sh"
    case bash = "/bin/bash"
    case zsh = "/bin/zsh"
}

final class ShellClient {
    
    private let shellType: ShellType
    
    init(shellType: ShellType = .zsh) {
        self.shellType = shellType
    }
    
    @discardableResult
    func runShell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: shellType.rawValue)
        task.standardInput = nil
        
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}
