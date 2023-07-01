//  ConnectionInfoFactory.swift

import Foundation

final class ConnectionInfoFactory {

    func makeConnectionsInfo(instances: [Instance], privateKeys: [PrivateKey]) -> [ConnectionInfo] {
        instances.compactMap { instance in
            guard let privateKey = privateKeys.first(where: { $0.instanceId == instance.instanceId }) else {
                return nil
            }
            return ConnectionInfo(instance: instance, privateKey: privateKey)
        }
    }
}
