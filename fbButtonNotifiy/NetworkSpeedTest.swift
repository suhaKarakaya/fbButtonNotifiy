//
//  NetworkSpeedTest.swift
//  fbButtonNotifiy
//
//  Created by Süha Karakaya on 23.07.2024.
//

import Foundation
import UIKit

protocol NetworkSpeedProviderDelegate: AnyObject {
    func callWhileSpeedChange(networkStatus: NetworkStatus)
}
public enum NetworkStatus: String {
    case poor
    case good
    case disConnected
}


class NetworkSpeedTest: UIViewController {
    
    weak var delegate: NetworkSpeedProviderDelegate?
    var startTime = CFAbsoluteTime()
    var stopTime = CFAbsoluteTime()
    var bytesReceived: CGFloat = 0
    var testURL:String?
    var speedTestCompletionHandler: ((_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void)? = nil
    var timerForSpeedTest:Timer?
    
    func networkSpeedTestStart(UrlForTestSpeed:String!){
        testURL = UrlForTestSpeed
        timerForSpeedTest = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(testForSpeed), userInfo: nil, repeats: true)
    }
    func networkSpeedTestStop(){
        timerForSpeedTest?.invalidate()
    }
    @objc func testForSpeed()
    {
        testDownloadSpeed(withTimout: 2.0, completionHandler: {(_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void in
            print("%0.1f; KbPerSec = \(megabytesPerSecond)")
            if (error as NSError?)?.code == -1009
            {
                self.delegate?.callWhileSpeedChange(networkStatus: .disConnected)
            }
            else if megabytesPerSecond == -1.0
            {
                self.delegate?.callWhileSpeedChange(networkStatus: .poor)
            }
            else
            {
                self.delegate?.callWhileSpeedChange(networkStatus: .good)
            }
        })
    }
}

extension NetworkSpeedTest: URLSessionDataDelegate, URLSessionDelegate {
    
    func testDownloadSpeed(withTimout timeout: TimeInterval, completionHandler: @escaping (_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void) {
        
        let urlForSpeedTest = URL(string: testURL!)
        startTime = CFAbsoluteTimeGetCurrent()
        stopTime = startTime
        bytesReceived = 0
        speedTestCompletionHandler = completionHandler
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        guard let checkedUrl = urlForSpeedTest else { return }
        session.dataTask(with: checkedUrl).resume()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bytesReceived += CGFloat(data.count)
        stopTime = CFAbsoluteTimeGetCurrent()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let elapsed = (stopTime - startTime)
        let speedInKBps: CGFloat = elapsed != 0 ? bytesReceived / (CGFloat(CFAbsoluteTimeGetCurrent() - startTime)) / 1024.0 : -1.0
        
        let speedInMbps: CGFloat = speedInKBps * 8 / 1024.0
        
        if error == nil || ((((error as NSError?)?.domain) == NSURLErrorDomain) && (error as NSError?)?.code == NSURLErrorTimedOut) {
            speedTestCompletionHandler?(speedInMbps, nil)
        } else {
            speedTestCompletionHandler?(speedInMbps, error)
        }
    }
}


