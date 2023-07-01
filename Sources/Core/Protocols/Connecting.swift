//  Connecting.swift

import Foundation

protocol Connecting {
    func connectToInstance(fleetIndex: Int) throws
    func connectToAllInstances() throws
}
