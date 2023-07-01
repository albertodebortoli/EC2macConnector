//  PrivateKey.swift

import Foundation

struct PrivateKey {
    let name: String
    let secretId: String
    let content: String
    let instanceId: String
}

extension PrivateKey {
    var privateKeyFilename: String {
        "\(name)_\(instanceId)"
    }
}

extension PrivateKey: CustomDebugStringConvertible {
    
    var debugDescription: String {
"""

Private Key (InstanceId: \(instanceId)):
  - Name: \(name)
  - SecretId: \(secretId)

"""
    }
}
