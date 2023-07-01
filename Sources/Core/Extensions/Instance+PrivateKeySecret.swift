//  Instance+PrivateKeySecret.swift

import Foundation

extension Instance {
    
    private enum SecretsManagerError: Error {
        case missingSecretForKeyPair(String)
    }
    
    /**
     This method performs the custom conversion from the instance key pair to the corresponding secret ID prefix
     so that EC2macConnector can fetch the most recent secret with the given prefix.
     */
    func correspondingKeyPairSecretIdPrefix(with secretsPrefix: String, separator: String = "_") throws -> String {
        let components = keyPair.components(separatedBy: separator)
        guard components.count > 1, let index = components.last else {
            throw SecretsManagerError.missingSecretForKeyPair(keyPair)
        }
        return "\(secretsPrefix)_\(index)_"
    }
}
