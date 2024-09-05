//
//  ThyNetworkSpeedTest.swift
//  ThyNetworkSpeedTest
//
//  Created by Süha Karakaya on 22.07.2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    let testURL = URL(string: "https://mdtest.limakcimento.com/android/tt.zip")!
    
    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), reqDate: convertDatetoString(date: Date()), resDate: convertDatetoString(date: Date()))
        SimpleEntry(date: Date(), reqDate: convertDatetoString(date: Date()), speedNetwork: 0.0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), reqDate: convertDatetoString(date: Date()), speedNetwork: 0.0)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        var entries: [SimpleEntry] = []
        
//        fetchValueFromService { res in
//            for minuteOffset in 0..<24 {
//                let entryDate = Calendar.current.date(byAdding: .minute, value: 15 * minuteOffset, to: currentDate)!
//                let entry = SimpleEntry(date: Date(), reqDate: convertDatetoString(date: Date()), resDate: res)
//                entries.append(entry)
//            }
//            
//            let timeline = Timeline(entries: entries, policy: .after(currentDate.addingTimeInterval(15 * 60)))
//            completion(timeline)
//        }
        
        measureDownloadSpeed(from: testURL) { speed in
             if let speed = speed {
                 for minuteOffset in 0..<24 {
                     let entryDate = Calendar.current.date(byAdding: .minute, value: 15 * minuteOffset, to: currentDate)!
                     let entry = SimpleEntry(date: Date(), reqDate: convertDatetoString(date: Date()), speedNetwork: speed)
                     entries.append(entry)
                 }
             } else {
                 for minuteOffset in 0..<24 {
                     let entryDate = Calendar.current.date(byAdding: .minute, value: 15 * minuteOffset, to: currentDate)!
                     let entry = SimpleEntry(date: Date(), reqDate: "patladık", speedNetwork: 0.0)
                     entries.append(entry)
                 }
             }
            
            let timeline = Timeline(entries: entries, policy: .after(currentDate.addingTimeInterval(15 * 60)))
            completion(timeline)
            
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

    
    
    
    func fetchValueFromService(completion: @escaping (String) -> Void) {
        
        
        
        let url = URL(string: "https://mdtest.limakcimento.com/cevik/api/gateway")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        let parameters: [String: Any] = [
            "method": "customService",
            "app_id": "363e61c4-affe-4352-b693-397a750b6b60",
            "include_player_ids": "c386580b-959b-49b2-9e6f-61c1920fa953",
            "reqTime": convertDatetoString(date: Date())
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            //            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? CustomResponse {
            //                completion("Response JSON: \(json)")
            //            } else {
            //                completion("Invalid JSON")
            //            }
            
            
            
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(CustomResponse.self, from: data)
                completion(response.resTime)
            } catch {
                completion("Invalid JSON")
            }
        }
        
        task.resume()
    }
}

private func convertDatetoString (date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: date)
}

struct CustomResponse: Codable {
    let resTime: String
}


struct SimpleEntry: TimelineEntry {
    let date: Date
    let reqDate: String
//    let resDate: String
    let speedNetwork: Double
}

struct ThyNetworkSpeedTestEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
//            Text("date:")
//            Text(entry.date, style: .time)
            
            Text("req:")
            Text(entry.reqDate)
            
//            Text("res:")
//            Text(entry.resDate)
            Text("Speed:")
            Text(String(format: "%.3f", entry.speedNetwork))
                        .font(.largeTitle)
                        .padding()
        }
    }
}

struct ThyNetworkSpeedTest: Widget {
    let kind: String = "MyWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ThyNetworkSpeedTestEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ThyNetworkSpeedTestEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemMedium) {
    ThyNetworkSpeedTest()
} timeline: {
    SimpleEntry(date: Date(), reqDate: convertDatetoString(date: Date()), speedNetwork: 0.0)
}
