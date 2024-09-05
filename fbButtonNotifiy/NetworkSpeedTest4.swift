//
//  NetworkSpeedTest4.swift
//  fbButtonNotifiy
//
//  Created by Süha Karakaya on 31.07.2024.
//

import Foundation
import SwiftyPing

class NetworkSpeedTest4 {
    
    init() {}
    
    
    private func getCurrentTime() -> UInt64 {
        return DispatchTime.now().uptimeNanoseconds
    }
    
    
    func measureBandwidth(completion: @escaping (Double) -> Void) {
        let url = URL(string: "https://mdtest.limakcimento.com/android/tt.zip")!
        let startTime = getCurrentTime()

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, error == nil {
                let endTime = self.getCurrentTime()
                let sure = Double(endTime - startTime) / 1_000_000_000
                let bandwidth = Double(data.count) * 8.0 / sure // bits per second
                completion(bandwidth)
            } else {
                completion(0)
            }
        }
        task.resume()
//        let now = DispatchTime.now()
//        let nanos = now.uptimeNanoseconds
//        print("Current time in nanoseconds: \(nanos)")
    }
    
    func measureLatency(completion: @escaping (Double) -> Void) {
        let pinger = try? SwiftyPing(host: "172.30.217.20", configuration: PingConfiguration(interval: 0.1, with: 10), queue: DispatchQueue.global())

        var totalDuration: Double = 0
        var count: Int = 0

        pinger?.observer = { response in
            totalDuration += response.duration * 1000 // Milisaniyeye çeviriyoruz
            count += 1
            if count == 10 {
                completion(totalDuration / Double(count)) // Ortalama milisaniye süresi
                pinger?.stopPinging()
            }
        }

        try? pinger?.startPinging()
    }
    
    func calculateBDP(bandwidth: Double, latency: Double) -> Double {
        return bandwidth * latency
    }

}



