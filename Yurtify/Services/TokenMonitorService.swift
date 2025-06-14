//
//  TokenMonitorService.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Foundation

final class TokenMonitorService {
    private var monitoringTask: Task<Void, Never>?
    
    func startMonitoring(tokenHandler: @escaping @MainActor () async -> Void) {
        stopMonitoring()
        
        monitoringTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                
                guard !Task.isCancelled else { break }
                
                await tokenHandler()
            }
        }
    }
    
    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
    }
    
    deinit {
        stopMonitoring()
    }
}
