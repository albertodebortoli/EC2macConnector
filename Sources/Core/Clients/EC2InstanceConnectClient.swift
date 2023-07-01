//  EC2InstanceConnectClient.swift

import SotoEC2InstanceConnect

final class EC2InstanceConnectClient {
    
    private let ec2InstanceConnect: EC2InstanceConnect
    
    init(region: String) {
        ec2InstanceConnect = EC2InstanceConnect(client: AWSClient.default, region: Region(rawValue: region))
    }
    
    func sendPublicSSHKey(
        availabilityZone: String,
        instanceId: String,
        instanceOSUser: String,
        sshPublicKey: String
    ) async throws -> Bool {
        let request = EC2InstanceConnect.SendSSHPublicKeyRequest(
            availabilityZone: availabilityZone,
            instanceId: instanceId,
            instanceOSUser: instanceOSUser,
            sshPublicKey: sshPublicKey
        )
        let response = try await ec2InstanceConnect.sendSSHPublicKey(request)
        return response.success ?? false
    }
}
