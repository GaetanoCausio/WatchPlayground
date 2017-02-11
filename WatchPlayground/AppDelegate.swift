//
//  AppDelegate.swift
//  WatchPlayground
//
//  Created by Gaetano Causio on 19/01/2017.
//  Copyright © 2017 Gaetano Causio. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let timerManager = TimerManager.sharedTimerManager
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        LogManager.display(forTypes: [.LifeCycle])
        
        // Activate Watch Connectivity Session
        
        if WCSession.isSupported() {
            LogManager.display(message: "Activating Watch Session...", forTypes: [.Debug])
            let defaultSession = WCSession.default()
            defaultSession.delegate = WatchConnectivityManager.sharedConnectivityManager
            defaultSession.activate()
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        LogManager.display(forTypes: [.LifeCycle])

        DispatchQueue.main.async { // this is needed as the request comes from another device (being a background task not running on main queue)
            self.timerManager.stop()
            _ = WatchConnectivityManager.sendMessage(["Stop" : DeviceID.iPhone])
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        LogManager.display(forTypes: [.LifeCycle])
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        LogManager.display(forTypes: [.LifeCycle])
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        LogManager.display(forTypes: [.LifeCycle])
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        LogManager.display(forTypes: [.LifeCycle])
        
    }


}

