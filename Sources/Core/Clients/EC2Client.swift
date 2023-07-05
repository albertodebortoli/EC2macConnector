//  EC2Client.swift

import SotoEC2

final class EC2Client {
    
    private enum FilterName {
        static let type = "instance-type"
        static let state = "instance-state-name"
        static let fleetIndexTag = "tag:EC2macConnector:FleetIndex"
    }
    
    private enum MacInstanceType: String, CaseIterable {
        case mac1metal = "mac1.metal"
        case mac2metal = "mac2.metal"
    }
    
    private enum Tags {
        static let fleetIndex = "EC2macConnector:FleetIndex"
    }
    
    private let ec2: EC2
    
    init(region: String) {
        ec2 = EC2(client: AWSClient.default, region: Region(rawValue: region))
    }
    
    func listRunningInstances() async throws -> [Instance] {
        try await listInstances(of: MacInstanceType.allCases, in: ["running"])
    }
    
    // MARK: - Private
    
    private func listInstances(of types: [MacInstanceType] = [], in states: [String] = []) async throws -> [Instance] {
        var filters = [EC2.Filter]()
        if !types.isEmpty {
            let instanceTypeFilter = EC2.Filter(name: FilterName.type, values: types.map { $0.rawValue })
            filters.append(instanceTypeFilter)
        }
        if !states.isEmpty {
            let instanceStateFilter = EC2.Filter(name: FilterName.state, values: states)
            filters.append(instanceStateFilter)
        }
        let tagFilter = EC2.Filter(name: FilterName.fleetIndexTag, values: ["*"])
        filters.append(tagFilter)
        let request = EC2.DescribeInstancesRequest(filters: filters, maxResults: 100)
        let result = try await ec2.describeInstances(request)
        let reservations = result.reservations ?? []
        return reservations
            .compactMap { $0.instances }
            .flatMap { $0 }
            .compactMap { makeInstance(from: $0) }
            .sorted(by: { $0.fleetIndex < $1.fleetIndex })
    }
    
    private func makeInstance(from instance: EC2.Instance) -> Instance? {
        guard
            let instanceId = instance.instanceId,
            let fleetIndex = instance.tags?.first(where: { $0.key == Tags.fleetIndex })?.value,
            let fleetIndexInt = Int(fleetIndex),
            let keyPair = instance.keyName,
            let privateIpAddress = instance.privateIpAddress,
            let type = instance.instanceType?.rawValue,
            let state = instance.state?.name?.rawValue
        else {
            return nil
        }
        return Instance(
            instanceId: instanceId,
            fleetIndex: fleetIndexInt,
            keyPair: keyPair,
            ip: privateIpAddress,
            type: type,
            state: state
        )
    }
}
