//  AWSClient+Default.swift

import SotoCore

extension AWSClient {
    static let `default` = AWSClient(credentialProvider: .default, httpClientProvider: .createNew)
}
