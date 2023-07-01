//  Sequence+Async.swift

import Foundation

extension Sequence {
    func asyncCompactMap<T>(
        _ transform: (Element) async throws -> T?
    ) async rethrows -> [T] {
        var values = [T]()
        
        for element in self {
            if let transformedElement = try await transform(element) {
                values.append(transformedElement)
            }
        }
        
        return values
    }
}
