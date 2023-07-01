//  SecretsManagerClient.swift

import Foundation
import SotoSecretsManager

typealias SecretValue = String

final class SecretsManagerClient {
    
    private enum ClientError: Error {
        case cannotRetrieveSecretsListWithPrefix(String)
        case missingSecretValue
        case noSecretFoundWithPrefix(String)
    }
    
    private let secretsManager: SecretsManager
    
    init(region: String) {
        secretsManager = SecretsManager(client: AWSClient.default, region: Region(rawValue: region))
    }
    
    func retrieveSecret(secretName: String) async throws -> SecretEntry {
        let getSecretRequest = SecretsManager.GetSecretValueRequest(secretId: secretName)
        let response = try await secretsManager.getSecretValue(getSecretRequest)
        guard let secretString = response.secretString else {
            throw ClientError.missingSecretValue
        }
        return SecretEntry(name: secretName, value: secretString)
    }
    
    func retrieveFirstSecretWithPrefix(_ prefix: String) async throws -> SecretEntry {
        let matchPrefixFilter = SecretsManager.Filter(
            key: .name,
            values: [prefix])
        let listSecretsRequest = SecretsManager.ListSecretsRequest(
            filters: [matchPrefixFilter],
            includePlannedDeletion: false,
            maxResults: 1,
            sortOrder: .desc)
        let response = try await secretsManager.listSecrets(listSecretsRequest)
        guard let secretList = response.secretList else {
            throw ClientError.cannotRetrieveSecretsListWithPrefix(prefix)
        }
        guard secretList.count == 1, let secret = secretList.first, let secretName = secret.name else {
            throw ClientError.noSecretFoundWithPrefix(prefix)
        }
        return try await retrieveSecret(secretName: secretName)
    }
}
