//
//  NetworkMonitor.swift
//  FroopProof
//
//  Created by David Reed on 6/6/23.
//

import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")

    var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }

    private init() {
        self.monitor = NWPathMonitor()
        self.monitor.start(queue: queue)
    }
}

