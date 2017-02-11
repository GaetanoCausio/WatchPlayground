//
//  ExtensionDelegate.swift
//  WatchPlayground WatchKit Extension
//
//  Created by Gaetano Causio on 19/01/2017.
//  Copyright © 2017 Gaetano Causio. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    let timerManager = TimerManager.sharedTimerManager
    
    override init() {
        
        LogManager.display(forTypes: [.LifeCycle])
        
        super.init()
        
        // Activate Watch Connectivity Session
        
        if WCSession.isSupported() {
            LogManager.display(message: "Activating Watch Session...", forTypes: [.Debug])
            let defaultSession = WCSession.default()
            defaultSession.delegate = WatchConnectivityManager.sharedConnectivityManager
            defaultSession.activate()
        }
        
    }

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        LogManager.display(forTypes: [.LifeCycle])
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        LogManager.display(forTypes: [.LifeCycle])
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        
        LogManager.display(forTypes: [.LifeCycle])

        DispatchQueue.main.async { // this is needed as the request comes from another device (being a background task not running on main queue)
            self.timerManager.stop()
            _ = WatchConnectivityManager.sendMessage(["Stop" : DeviceID.watch])
        }

    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }

}
