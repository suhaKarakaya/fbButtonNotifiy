//
//  Counter.swift
//  ThyNetworkSpeedTestExtension
//
//  Created by Süha Karakaya on 24.07.2024.
//

import Foundation

class Counter {
    private var startTime: Date?
    private var totalElapsedTime: TimeInterval = 0
    
    func start() {
        if startTime == nil {
            startTime = Date()
        }
    }
    
    func stop() {
        if let start = startTime {
            totalElapsedTime += Date().timeIntervalSince(start)
            startTime = nil
        }
    }
    
    func getElapsedTime() -> TimeInterval {
        if let start = startTime {
            return totalElapsedTime + Date().timeIntervalSince(start)
        } else {
            return totalElapsedTime
        }
    }
    
    func printElapsedTime() {
        let elapsedTime = getElapsedTime()
        print("Elapsed Time: \(String(format: "%.2f", elapsedTime)) seconds")
    }
}

