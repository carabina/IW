//
//  IWAppDelegate.swift
//  haoduobaduo
//
//  Created by iWe on 2017/6/21.
//  Copyright © 2017年 iWe. All rights reserved.
//

import UIKit
import UserNotifications

class IWAppDelegate: UIResponder, UIApplicationDelegate {
    
    typealias IWADDeviceTokenHandler = (_ token: String?) -> Void
    typealias IWADReceiveRemoteNotificationHandler = (_ userInfo: [AnyHashable: Any]) -> Void
    
    var deviceTokenHandler: IWADDeviceTokenHandler?
    var receiveRemoteNotificationHandler: IWADReceiveRemoteNotificationHandler?
    
    func remoteNotification(_ tokenHandler: IWADDeviceTokenHandler?, _ receiveHanlder: IWADReceiveRemoteNotificationHandler?) -> Void {
        
        if tokenHandler != nil {
            deviceTokenHandler = tokenHandler!
        }
        if receiveHanlder != nil {
            receiveRemoteNotificationHandler = receiveHanlder!
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Register for remote notifications with device token.
        
        let token = deviceToken.deviceToken
        if let tokenHandler = deviceTokenHandler {
            tokenHandler(token)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        iPrint("Did fail to register for remote notifications with error", error: error)
    }
    
    // iOS 3 - 9
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        switch application.applicationState {
            case .active: do {
            	iPrint("in active")
            }
        	case .background: do {
            	iPrint("in background")
            }
        	case .inactive: do {
            	iPrint("in inactive")
            }
        }
        
        if let receive = receiveRemoteNotificationHandler {
            receive(userInfo)
        }
    }
    
    // iOS 7 or later
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let receive = receiveRemoteNotificationHandler {
            receive(userInfo)
        }
    }
    
}


extension IWAppDelegate: UNUserNotificationCenterDelegate {
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Will present 程序正在运行时 收到通知
        if notification.request.trigger is UNPushNotificationTrigger {
            // Remote notification
            if let receive = receiveRemoteNotificationHandler {
                receive(notification.request.content.userInfo)
            }
        } else {
            // Non remote notification
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Did receive 程序在后台/不活动时 收到通知
        if response.notification.request.trigger is UNPushNotificationTrigger {
            // Remote notification
            if let receive = receiveRemoteNotificationHandler {
                receive(response.notification.request.content.userInfo)
            }
        } else {
            // Non remote notification
        }
        completionHandler()
    }
    
    
    func registRemoteNotifications(_ application: UIApplication, _ result: ((Bool) -> Void)? = nil) {
        
        if #available(iOS 10, *) {
            // iOS10 or later
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            let types10: UNAuthorizationOptions = [.badge, .alert, .sound]
            center.requestAuthorization(options: types10, completionHandler: { (granted, error) in
                if granted {
                    self.executeResultHandler(true, result, "User allows remote notification.")
                } else {
                    self.executeResultHandler(false, result, "The user does not allow remote notifications.")
                }
            })
            
        } else  {

			// iOS8 or later
			if let currentSettings = application.currentUserNotificationSettings {
				if currentSettings.types != .init(rawValue: 0) {
					self.executeResultHandler(true, result, "User allows remote notification.")
				} else {
					
					// Not the first launch app
					self.executeResultHandler(false, result, "The user does not allow remote notifications.")
				}
			} else {
				
				// First launch app
				self.executeResultHandler(false, result, "The user does not allow remote notifications.")
			}
			
			let settings: UIUserNotificationSettings = .init(types: [.badge, .alert, .sound], categories: nil)
			application.registerUserNotificationSettings(settings)

			/*
            if #available(iOS 8, *) {
            } else {
                // iOS 8 and below
                application.registerForRemoteNotifications(matching: [.alert, .badge, .sound])
            } */
        }
        
        // Regist and get Token
        application.registerForRemoteNotifications()
    }
    
    private func executeResultHandler(_ result: Bool, _ handler: ((Bool) -> Void)? = nil, _ log: String) {
        iPrint(log)
        if let hd = handler {
            hd(result)
        }
    }
}
