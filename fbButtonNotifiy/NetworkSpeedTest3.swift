//
//  NetworkSpeedTest3.swift
//  fbButtonNotifiy
//
//  Created by Süha Karakaya on 25.07.2024.
//

import Foundation
import SwiftyPing

class NetworkSpeedTest3 {
    
    init() {}
    
    let tcpWindowSize: Double = 64 * 1024 * 8 // 64 KB, bit cinsinden (64 KB = 65,536 byte = 524,288 bit)
    
    func calculateBDP(bandwidth: Double, latency: Double) -> Double {
        return bandwidth * latency
    }
    
    func calculateMaxTCPConnections(bdp: Double, tcpWindowSize: Double) -> Double {
        return bdp / tcpWindowSize
    }
    
    func measureLatency(completion: @escaping (Double?) -> Void) {
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
    
    func measureBandwidth(completion: @escaping (Double?) -> Void) {
        let url = URL(string: "https://mdtest.limakcimento.com/android/deneme.txt")!
        var request = URLRequest(url: url)
        request.setValue("identity", forHTTPHeaderField: "Accept-Encoding") // Sıkıştırmayı önler
        
        let startTime = Date()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            let expectedDataSize = 64 * 1024 // 64 KB = 65,536 byte
            if data.count != expectedDataSize {
                print("Beklenen dosya boyutu: \(expectedDataSize) byte, alınan dosya boyutu: \(data.count) byte")
                completion(nil)
                return
            }
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            let dataSize = Double(data.count) * 8 // Byte to bit
            let bandwidth = dataSize / elapsedTime // bit per second
            
            completion(bandwidth)
        }
        
        task.resume()
    }
    
    func measureNetworkParametersAndCalculateTCPConnections() {
        measureLatency { latency in
            guard let latency = latency else {
                print("Gecikme süresi ölçülemedi")
                return
            }

            self.measureBandwidth { bandwidth in
                guard let bandwidth = bandwidth else {
                    print("Bant genişliği ölçülemedi")
                    return
                }

                let bdp = self.calculateBDP(bandwidth: bandwidth, latency: latency / 1000) // Milisaniyeyi saniyeye çeviriyoruz
                let maxTCPConnections = self.calculateMaxTCPConnections(bdp: bdp, tcpWindowSize: self.tcpWindowSize)

                print("Gecikme Süresi: \(latency) ms")
                print("Bant Genişliği: \(bandwidth) bit/saniye")
                print("Bant Genişliği-Gecikme Ürünü (BDP): \(bdp) bit")
                print("Maksimum TCP Oturum Sayısı: \(maxTCPConnections)")
            }
        }
    }
}

