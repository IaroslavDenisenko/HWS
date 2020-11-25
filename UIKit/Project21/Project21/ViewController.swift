//
//  ViewController.swift
//  Project21
//
//  Created by Iaroslav Denisenko on 25.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    var timeInterval = 6.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
    }

    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Ya-h!")
            } else {
                print("D'oh")
            }
        }
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        let remind = UNNotificationAction(identifier: "remind", title: "Remind me later", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remind], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }

    @objc func scheduleLocal() {
        registerCategories()
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "alarm"
        content.userInfo = ["CustomInfo": "fizzbuzz" ]
        
        var dateComponents = DateComponents()
        dateComponents.hour = 17
        dateComponents.minute = 50
        
//        let triger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        center.removeAllPendingNotificationRequests()
        
        let triger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: triger)
        
        center.add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if let customData = userInfo["CustomInfo"] as? String {
            print("Custom info: \(customData)")
        }
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            showAlert(title: "DefaultAction", message: "the user swiped to unlock", actionTitle: "OK", handler: nil)
        case "show":
            showAlert(title: "ShowAction", message: "the user tapped our show more info… button", actionTitle: "OK", handler: nil)
        case "remind":
            timeInterval = 86400
            scheduleLocal()
        default:
            break
        }
        completionHandler()
    }
    
    func showAlert(title: String?, message: String?, actionTitle: String?, handler: ((UIAlertAction) -> Void)?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        present(ac, animated: true)
    }
}

