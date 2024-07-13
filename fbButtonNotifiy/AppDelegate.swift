//
//  AppDelegate.swift
//  fbButtonNotifiy
//
//  Created by Süha Karakaya on 2.07.2024.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    static var token: String = ""
    static var response: String = ""
    var customPlayer: CustomAudioPlayer?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        setupNotificationActions()
        
        return true
    }
    
    func requestNotificationAuthorization() {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        
//        // Bildirimi işle
//        if let aps = userInfo["aps"] as? [String: AnyObject],
//           let alert = aps["alert"] as? [String: AnyObject],
//           let title = alert["title"] as? String,
//           let body = alert["body"] as? String {
//            
//            // Bildirimi göster (isteğe bağlı)
//            let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//            
//            // Veri alanını işle (isteğe bağlı)
//            if let data = userInfo["data"] as? [String: Any] {
//                if let key1 = data["key1"] as? String {
//                    print("key1: \(key1)")
//                    // Key1'e göre işlemler yapabilirsiniz
//                }
//                if let key2 = data["key2"] as? String {
//                    print("key2: \(key2)")
//                    // Key2'ye göre işlemler yapabilirsiniz
//                }
//            }
//            
//            // Bildirim kategorisine göre işlem yap (isteğe bağlı)
//            if let category = aps["category"] as? String {
//                switch category {
//                case "CATEGORY_IDENTIFIER":
//                    if let action = userInfo["action"] as? String {
//                        if action == "START_BUTTON" {
//                            customPlayer?.send(true, completion: { res in
//                                AppDelegate.response = res
//                            })
//                        } else if action == "START_BUTTON" {
//                            customPlayer?.send(false, completion: { res in
//                                AppDelegate.response = res
//                            })
//                        }
//                    }
//                default:
//                    break
//                }
//            }
//        }
//        
//        // İşlem tamamlandığında completionHandler() fonksiyonunu çağırarak bildirimi tamamla
//        completionHandler(.newData)
//    }
//    
//    
    @available(iOS 10, *)
    func setupNotificationActions() {
        let startButton = UNNotificationAction(identifier: "START_BUTTON",
                                               title: "start",
                                               options: [])
        let stopButton = UNNotificationAction(identifier: "STOP_BUTTON",
                                              title: "stop",
                                              options: [])
        let category = UNNotificationCategory(identifier: "CATEGORY_IDENTIFIER",
                                              actions: [startButton,stopButton],
                                              intentIdentifiers: [],
                                              options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        customPlayer = CustomAudioPlayer()
        
        if response.actionIdentifier == "START_BUTTON" {
            customPlayer?.send(true, completion: { res in
                AppDelegate.response = res
            })
        } else if response.actionIdentifier == "STOP_BUTTON" {
            customPlayer?.send(false, completion: { res in
                AppDelegate.response = res
            })
        }
        completionHandler()
    }
    
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        AppDelegate.token = fcmToken ?? ""
        UserDefaults(suiteName: "group.com.yourapp.widgets")?.set(fcmToken, forKey: "token")
    }
}
