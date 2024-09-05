//
//  ViewController.swift
//  fbButtonNotifiy
//
//  Created by Süha Karakaya on 2.07.2024.
//

import UIKit
import SwiftyPing
import Dispatch

class ViewController: UIViewController, NetworkSpeedProviderDelegate {
    
    var test = NetworkSpeedTest()
    var tt = NetworkSpeedTest3()
    var ee = NetworkSpeedTest4()
//    var networkSpeedTest: NetworkSpeedTest2?
    
    let testURL = URL(string: "https://mdtest.limakcimento.com/android/tt.zip")!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        measureInternetSpeed()
        //        Do any additional setup after loading the view.
        //                measurePing()
//        test.delegate = self
//        test.networkSpeedTestStop()
//        test.networkSpeedTestStart(UrlForTestSpeed: "https://cachefly.cachefly.net/100mb.bin")
        
        // https://mdtest.limakcimento.com/android/deneme.txt
        // https://mdtest.limakcimento.com/android/tt.zip
        
//        networkSpeedTest = NetworkSpeedTest2()
//        networkSpeedTest?.delegate = self // delegate ataması yapılmalı
//        networkSpeedTest?.networkSpeedTestStart(UrlForTestSpeed: "https://cachefly.cachefly.net/100mb.bin")
        
//        tt.measureNetworkParametersAndCalculateTCPConnections()
        
//        var timer: Timer?
//
//        
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//             
//            self.measureDownloadSpeed(from: testURL) { speed in
//                 if let speed = speed {
//                     print("Download speed: \(speed) Mbps")
//                 } else {
//                     print("Failed to measure download speed")
//                 }
//             }
//         }
 
        
    }
    
    @IBAction func start(_ sender: Any) {
//        self.measureDownloadSpeed(from: testURL) { speed in
//             if let speed = speed {
//                 print("Download speed: \(speed) Mbps")
//             } else {
//                 print("Failed to measure download speed")
//             }
//         }
        
        ee.measureBandwidth { bandwidth in
            print("Bandwidth: \(bandwidth) bits/second")
            
            self.ee.measureLatency { latency in
                print("Latency: \(latency) seconds")
                
                let bdp = self.ee.calculateBDP(bandwidth: bandwidth, latency: latency)
                print("BDP: \(bdp) bits")
            }
        }
    }
    
    func measureDownloadSpeed(from url: URL, completion: @escaping (Double?) -> Void) {
        // Zaman ölçümünü başlatmak için yardımcı bir fonksiyon
        func getCurrentTime() -> UInt64 {
            var info = mach_timebase_info_data_t()
            mach_timebase_info(&info)
            let time = mach_absolute_time()
            let nanoseconds = time * UInt64(info.numer) / UInt64(info.denom)
            return nanoseconds
        }
        
        var startTime: UInt64 = 0
        var endTime: UInt64 = 0
        
        // URLSession yapılandırmasını ayarla
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60 // 60 saniye
        let session = URLSession(configuration: configuration)
        
        // Başlangıç zamanını al
        startTime = getCurrentTime()
        print("startTime: \(startTime) ns")
        
        // URLSession ile dosyayı indir
        let task = session.dataTask(with: url) { data, response, error in
            // Hata kontrolü
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Yanıt kontrolü
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                completion(nil)
                return
            }
            
            // Bitiş zamanını al
            endTime = getCurrentTime()
            print("endTime: \(endTime) ns")
            
            // Süreyi hesapla (nanosecond cinsinden)
            let duration = Double(endTime - startTime) / 1_000_000_000
            print("duration: \(duration) s")
            
            // Verinin boyutunu byte cinsinden al
            let dataSize = Double(data?.count ?? 0) / (1024 * 1024) // MB
            if duration > 0 {
                // Hızı hesapla (MB/s cinsinden)
                let speedMbps = (dataSize * 8) / duration // Mbps
                completion(speedMbps)
            } else {
                // Süre sıfırsa, hız hesaplanamaz
                completion(nil)
            }
        }
        
        task.resume()
    }

    
    
    func callWhileSpeedChange(networkStatus: NetworkStatus) {
        switch networkStatus {
        case .poor:
            break
        case .good:
            break
        case .disConnected:
            break
        }
    }
    
    
    
    //    func measurePing() {
    //
    //
    //        let jitterCalculator = JitterCalculator()
    //
    //        let pinger = try? SwiftyPing(host: "www.google.com", configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())
    //        pinger?.observer = { (response) in
    //            let duration = response.duration
    //            jitterCalculator.addDuration(duration)
    //            let jitter = jitterCalculator.calculateJitter()
    //            print("Ping duration: \(duration) seconds, Jitter: \(jitter) seconds")
    //        }
    //        try? pinger?.startPinging()
    //
    //    }
    //
    //    class JitterCalculator {
    //        private var pingDurations: [Double] = []
    //        private let maxDurations = 10 // Maximum number of durations to keep
    //
    //        func addDuration(_ duration: Double) {
    //            pingDurations.append(duration)
    //            if pingDurations.count > maxDurations {
    //                pingDurations.removeFirst()
    //            }
    //        }
    //
    //        func calculateJitter() -> Double {
    //            guard pingDurations.count > 1 else { return 0.0 }
    //
    //            var totalJitter: Double = 0.0
    //            var previousDuration = pingDurations[0]
    //
    //            for duration in pingDurations.dropFirst() {
    //                totalJitter += abs(duration - previousDuration)
    //                previousDuration = duration
    //            }
    //
    //            return totalJitter / Double(pingDurations.count - 1)
    //        }
    //    }
    
    func measureInternetSpeed() {
        let group = DispatchGroup()
        var results: [String: Any] = [:]
        
        // Measure Ping and Latency
        group.enter()
        measurePing { pingTime, latency, jitter in
            results["Ping"] = pingTime
            results["Latency"] = latency
            results["Jitter"] = jitter
            group.leave()
        }
        
        
        
        // Notify when all tasks are done
        group.notify(queue: .main) {
            print("All measurements are complete:")
            for (key, value) in results {
                print("\(key): \(value)")
            }
        }
    }
    
    func measurePing(completion: @escaping (TimeInterval?, TimeInterval?,  TimeInterval?) -> Void) {
        var latencies: [Double] = []
        var count = 0
        
        let pinger = try? SwiftyPing(host: "www.google.com", configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())
        pinger?.observer = { (response) in
            let duration = response.duration
            print("Ping duration: \(duration/1000) seconds")
            latencies.append(duration)
            let averageLatency = latencies.reduce(0, +) / Double(latencies.count)
            print("Average Latency: \(averageLatency/1000) seconds")
            let jitter = self.calculateJitter(from: latencies)
            print("Jitter: \(jitter / 1000) seconds")
            count += 1
            
            if count == 10 {
                completion((duration * 1000), (averageLatency * 1000), (jitter * 1000))
                pinger?.stopPinging()
            }
            
        }
        try? pinger?.startPinging()
        
        //    Ping: Test edilen bağlantının yanıt sürelerini ölçen bir araçtır.
        //    Latency: Bir veri paketinin hedefe gidip geri dönmesi için geçen süreyi ifade eder. Ping testi ile ölçülür.
        //    Jitter: Latency değerlerindeki değişkenliği ve dalgalanmayı ölçer.
        
    }
    
    func calculateJitter(from latencies: [Double]) -> Double {
        guard latencies.count > 1 else { return 0 }
        
        // Ortalama latency hesapla
        let meanLatency = latencies.reduce(0, +) / Double(latencies.count)
        
        // Latency varyansını hesapla
        let variance = latencies.map { pow($0 - meanLatency, 2) }.reduce(0, +) / Double(latencies.count)
        
        // Standart sapma olarak jitter hesapla
        let jitter = sqrt(variance)
        
        return jitter
    }
    
    
    
}

