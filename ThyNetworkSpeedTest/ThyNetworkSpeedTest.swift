//
//  ThyNetworkSpeedTest.swift
//  ThyNetworkSpeedTest
//
//  Created by Süha Karakaya on 22.07.2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), reqDate: convertDatetoString(date: Date()), resDate: convertDatetoString(date: Date()))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), reqDate: convertDatetoString(date: Date()), resDate: convertDatetoString(date: Date()))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        var entries: [SimpleEntry] = []
        
        fetchValueFromService { res in
            for minuteOffset in 0..<24 {
                let entryDate = Calendar.current.date(byAdding: .minute, value: 15 * minuteOffset, to: currentDate)!
                let entry = SimpleEntry(date: Date(), reqDate: convertDatetoString(date: Date()), resDate: res)
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .after(currentDate.addingTimeInterval(15 * 60)))
            completion(timeline)
        }
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
    let resDate: String
}

struct ThyNetworkSpeedTestEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text("date:")
            Text(entry.date, style: .time)
            
            Text("req:")
            Text(entry.reqDate)
            
            Text("res:")
            Text(entry.resDate)
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
    SimpleEntry(date: Date(), reqDate: convertDatetoString(date: Date()), resDate: convertDatetoString(date: Date()))
}
