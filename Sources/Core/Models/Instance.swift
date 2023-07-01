//  Instance.swift

import Foundation

struct Instance {
    let instanceId: String
    let fleetIndex: Int
    let keyPair: String
    let ip: String
    let type: String
    let state: String
}

extension Instance: CustomDebugStringConvertible {
    
    var debugDescription: String {
"""

Instance (Fleet Index #\(fleetIndex)):
  - InstanceId: \(instanceId)
  - KeyPair: \(keyPair)
  - IP: \(ip)
  - Type: \(type)
  - State: \(state)

"""
    }
}
