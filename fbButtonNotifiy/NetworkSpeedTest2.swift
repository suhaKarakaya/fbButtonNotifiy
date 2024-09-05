////
////  NetworkSpeedTest2.swift
////  fbButtonNotifiy
////
////  Created by Süha Karakaya on 24.07.2024.
////
//
//import Foundation
//import UIKit
//
//protocol NetworkSpeedProviderDelegate: AnyObject {
//    func callWhileSpeedChange(networkStatus: NetworkStatus)
//}
//
//public enum NetworkStatus: String {
//    case poor
//    case good
//    case disConnected
//}
//
//class NetworkSpeedTest2: UIViewController {
//
//    weak var delegate: NetworkSpeedProviderDelegate?
//    var startTime = CFAbsoluteTime()
//    var bytesReceived: CGFloat = 0
//    var testURL: String?
//    var speedTestCompletionHandler: ((_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void)? = nil
//    var timer: Timer?
//    var isTesting = false
//
//    func networkSpeedTestStart(UrlForTestSpeed: String!) {
//        testURL = UrlForTestSpeed
//        bytesReceived = 0
//        isTesting = true
//        startTime = CFAbsoluteTimeGetCurrent()
//        timer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(testEnd), userInfo: nil, repeats: false)
//        performTest()
//    }
//    
//    @objc func testEnd() {
//        isTesting = false
//        calculateSpeed()
//    }
//
//    func performTest() {
//        guard let url = URL(string: testURL!) else { return }
//        let session = URLSession(configuration: .ephemeral)
//        session.dataTask(with: url) { data, response, error in
//            if let data = data {
//                self.bytesReceived += CGFloat(data.count)
//                if self.isTesting {
//                    self.performTest() // Continue testing
//                }
//            } else {
//                // Handle error if needed
//                self.isTesting = false
//                self.calculateSpeed()
//            }
//        }.resume()
//    }
//    
//    func calculateSpeed() {
//        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
//        let speedInKBps: CGFloat = elapsed != 0 ? bytesReceived / (CGFloat(elapsed)) / 1024.0 : -1.0
//        let speedInMbps: CGFloat = speedInKBps * 8 / 1024.0
//        let megabytesPerSecond: CGFloat = speedInMbps / 8.0
//        
//        print("Final Speed: \(megabytesPerSecond) MBps")
//        speedTestCompletionHandler?(megabytesPerSecond, nil)
//    }
//}
