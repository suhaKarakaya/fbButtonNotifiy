//
//  CustomAudioPlayer.swift
//  fbButtonNotifiy
//
//  Created by Süha Karakaya on 3.07.2024.
//

import Foundation
import Alamofire
import PythonKit

class CustomAudioPlayer {
    
    var timer: Timer?
    
    init() {
        
    }
    
    
    func runPythonScript() {
        // Proje dizinindeki apple.py dosyasının yolunu belirtin
        guard let scriptPath = Bundle.main.path(forResource: "apple", ofType: "py") else {
            print("apple.py dosyası bulunamadı")
            return
        }
        
        // PythonKit kullanarak subprocess modülünü içe aktar
        let sys = Python.import("sys")
        sys.path.append(scriptPath)
        
        let subprocess = Python.import("subprocess")
        
        do {
            // Python betiğini çalıştır ve çıktıyı al
            let result = subprocess.run(["python3", scriptPath], capture_output: true, text: true)
            let output = result.stdout
            print("Python script output: \(output)")
        } catch {
            print("Failed to run Python script: \(error)")
        }
    }
    
    func makeRequest(_ flag: Bool) {
        let url = URL(string: "https://mdtest.limakcimento.com/cevik/api/gateway")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        let parameters: [String: Any] = [
            "method": "customService",
            "timerOn": true,
            "token": "eOb2HID2t0Q7m4s5AlcE0s:APA91bGwebZ0Jp1ZPeKhFdCDJSAa7v3JVt63ZOM9EuLHYer0a_xpc3Z-kQNHpSN1gs51pll9wHUerLyAAByddfHqo1Wakj3Qo_RldcRkB3oXsh0RDMcQwXZrqeTnqObthZxzQco-yRXZ",
            "ya": "Bearer ya29.c.c0ASRK0GaNErZifroM62gWAOlm1GXeJueoxrM0VP24Q9q5JuDDlydvJJG_nYY-MGofE9-3aeUUTyIDWf19yraE57Qqq3Bedm54nNEQroXm7jztJGxousIDGC1rRcZ0R8jxOjhVmD_kKTpsPoHavgD0emzqqD94XjflxkMfd_U1Ok7swTGg2Wcv942B6SLKXAKEJAWjuO278BqHU9aA5vZMRYxYVAXY0AzzJiCof7Xr3q7K1Ko_f9VUKaiD8egn4z3SLA1MPHbRieTOcuuX4w80_WchK2fNgHz3-iiid4LE2txq6SXnTtteRxRLqkuo9nOgPkhiHfeLlEiMCjHIeRekYSqoXaAfRBOPVVCr8fsNC81px3Ifl99uGufvL385KMIxO8nasX-uYks_SS-gn-eqoqYeVn49t60jyqMsks2Icpp0c0zZ8ymF98tfbx5z6fru1R1hstep1qou9QU0cyew2m8Bv8M09oxukORWg6fsdXq9Vcy9J109ecsF0iRWO9VWWR_qYUlm05otrSgadszs42d5SFSgt_bQbta8i8ekz-gRpyJpxF3Yne8ISFMdwzejSOz-o17x2k3krah_zaZ1i_rigfimvI1VnahSpibqji1ZIxynJdpw-OzVbQd5Sub7i0nVY788c1fqqZgIlzvve63eMSmnQks710c6u1F4OmYRx_ZW9S6pWkcgS2WpaQYX9FBMx0c9UB6i0xFg74hpVzehU599M495w27Mh_d_2-O7u4r9rgeilYbWgRisUm7mq0jzea9M_66ziOpWFo_dmrJzF9skbp6joQq6zey4OsxIit1sq11m8g5nhmZqIMQwS292Sj14pq5d4W738-VdwW5dpZx3Y53zt7B3rWg4zuefcWB0r-YzuJM0c95_1Q95nxpuo9UZkFbd78WiVaig7jJw7Yfdwjt9zkdsetseUZn-foM4ZhWsIJysZUM5aykagXwsI6piBMw91sruuZ8M5YS2lUMzgQbYbIS2mhvsmeZW7qOgmqFczrO"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
//                completion("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                completion("Response JSON: \(json)")
            } else {
//                completion("Invalid JSON")
            }
        }
        
        task.resume()
    }
    
    
    func send(_ flag: Bool, completion: @escaping (String) -> Void){
        //        runPythonScript()
        
        if let existingTimer = timer, existingTimer.isValid {
            // Eğer timer zaten çalışıyorsa, durdur ve yeniden başlat
            existingTimer.invalidate()
            timer = nil
        }
        
        makeRequest(flag)
//        debugPrint("servis çık \(Date())")
//        
//        if flag {
//            timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
//                self.makeRequest(flag)
//                debugPrint("servis çık \(Date())")
//                
//            }
//        } else {
//            if let existingTimer = timer, existingTimer.isValid {
//                // Eğer timer zaten çalışıyorsa, durdur ve yeniden başlat
//                existingTimer.invalidate()
//                timer = nil
//            }
//        }
    }
}
