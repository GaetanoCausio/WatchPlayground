//
//  WatchTestController.swift
//

import WatchKit
import Foundation

class WatchTestController: WKInterfaceController, TimerManagerDelegate, WatchConnectivityManagerWatchDelegate {

    // --------------------------
    // MARK: - Outlets
    // --------------------------

    @IBOutlet var watchCounterLabel: WKInterfaceLabel!
    @IBOutlet var iPhoneCounterLabel: WKInterfaceLabel!
    @IBOutlet var startStopWatchButtonLabel: WKInterfaceButton!
    @IBOutlet var startStopIPhoneButtonLabel: WKInterfaceButton!

    // --------------------------
    // MARK: - Actions
    // --------------------------

    @IBAction func startStopWatchButton() {
        
        LogManager.display(forTypes: [.UserAction])
 
        self.startStopWatchButtonLabel.setTitle("Wait")
        
        if buttonWatchStatus == .Stopped {
            timerManager.start(interval: timerInterval)
            _ = WatchConnectivityManager.sendMessage(["Start" : DeviceID.watch])
        } else {
            timerManager.stop()
            _ = WatchConnectivityManager.sendMessage(["Stop" : DeviceID.watch])
        }
    }

    @IBAction func startStopIPhoneButton() {
        
        LogManager.display(forTypes: [.UserAction])
        
        self.startStopIPhoneButtonLabel.setTitle("Wait")
        
        if buttonIPhoneStatus == .Stopped {
            _ = WatchConnectivityManager.sendMessage(["Start" : DeviceID.iPhone])
        } else {
            _ = WatchConnectivityManager.sendMessage(["Stop" : DeviceID.iPhone])
        }
    }
    
    // --------------------------
    // MARK: - Implementation
    // --------------------------
    
    let timerManager = TimerManager.sharedTimerManager
    
    var buttonIPhoneStatus: ButtonStatus = .Stopped {
        willSet {
            DispatchQueue.main.async { // this is needed as the request comes from another device (being a background task not running on main queue)
                // set button label accordingly
                if newValue == .Started {
                    self.startStopIPhoneButtonLabel.setTitle("Stop")
                } else {
                    self.startStopIPhoneButtonLabel.setTitle("Start")
                }
            }
        }
    }
    var buttonWatchStatus: ButtonStatus = .Stopped {
        willSet {
            DispatchQueue.main.async { // this is needed as the request comes from another device (being a background task not running on main queue)
                // set button label accordingly
                if newValue == .Started {
                    self.startStopWatchButtonLabel.setTitle("Stop")
                } else {
                    self.startStopWatchButtonLabel.setTitle("Start")
                }
            }
        }
    }
    
    func updateUI() {
        
        // display counters value
        
        let counter = timerManager.counter()
        watchCounterLabel.setText("\(counter)")

        // set button label accordingly
        
        if timerManager.isStarted() {
            buttonWatchStatus = .Started
        } else {
            buttonWatchStatus = .Stopped
        }

        LogManager.display(message: "Timer Watch is \(buttonWatchStatus.rawValue). Current count is \(counter)", forTypes: [.Debug])
        
        // Send counter value to connected device
        _ = WatchConnectivityManager.sendMessage(["Timer" : DeviceID.watch, "Counter": counter])
        
    }
    
    // --------------------------------
    // MARK: - Implement Timer protocol
    // --------------------------------
    
    func timerUpdated() {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        LogManager.display(message: "Timer Count updated for device Watch", forTypes: [.Debug])
        
        updateUI()
    }
    
    func timerStopped() {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        LogManager.display(message: "Timer Stopped for device Watch", forTypes: [.Debug])
        
        updateUI()
        
    }
    
    func timerStarted() {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        LogManager.display(message: "Timer Started for device Watch", forTypes: [.Debug])
        
        updateUI()
        
    }
    
    // --------------------------------------------
    // MARK: - Implement WatchConnectivity protocol
    // --------------------------------------------
    
    func didReceive(message: [String : Any]) {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        LogManager.display(message: "Reveiced message: \(message)", forTypes: [.Debug,.WatchConnection])
        
        if let device = message["Start"] as? String {
        
            if device == DeviceID.watch {
                
                // an external request has been received to start the watch timer
                buttonWatchStatus = .Started
                DispatchQueue.main.async { // this is needed as the request comes from another device (being a background task not running on main queue)
                    self.timerManager.start(interval: timerInterval)
                }
                
                // Inform requester that we actually started the timer
                _ = WatchConnectivityManager.sendMessage(["Start" : DeviceID.watch])
                
            } else if device == DeviceID.iPhone {
                
                // an external device has started its timer, reflect the change here
                buttonIPhoneStatus = .Started
                
            }
            
        } else if let device = message["Stop"] as? String {
            
            if device == DeviceID.watch {
                
                // an external request has been received to stop the watch timer
                buttonWatchStatus = .Stopped
                DispatchQueue.main.async { // this is needed as the request comes from another device (being a background task not running on main queue)
                    self.timerManager.stop()
                }
                
                // Inform requester that we actually stopped the timer
                _ = WatchConnectivityManager.sendMessage(["Stop" : DeviceID.watch])
                
            } else if device == DeviceID.iPhone {
                
                // an external device has stopped its timer, reflect the change here
                buttonIPhoneStatus = .Stopped
                
            }
            
        } else if let device = message["Timer"] as? String {
            
            if device == DeviceID.iPhone {
                
                // we received a request to reflect our UI from processing of an external device
                // this needs to be done on the main thread as the request start from a background process
                
                if let counter = message["Counter"] as? Int {
                    
                    // update counter of connected device
                    
                    DispatchQueue.main.async {
                        self.iPhoneCounterLabel.setText("\(counter)")
                        
                    }
                }
                
            }
            
        } else if let device = message["Reset"] as? String {
            
            if device == DeviceID.watch {

                // an external request has been received to reset the watch timer
                buttonWatchStatus = .Stopped
                DispatchQueue.main.async { // this is needed as the request comes from another device (being a background task not running on main queue)
                    self.timerManager.reset()
                }
                
                // Inform requester that we actually stopped the timer
                _ = WatchConnectivityManager.sendMessage(["Stop" : DeviceID.watch])
                

            }
        }
        
        

    }
    
    // --------------------------
    // MARK: - Life cycle
    // --------------------------
    
    override func awake(withContext context: Any?) {

        super.awake(withContext: context)
        
        LogManager.display(forTypes: [.LifeCycle])
        
        // Configure interface objects here.
    }

    override func willActivate() {

        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        LogManager.display(forTypes: [.LifeCycle])
        
        timerManager.delegate = self
        WatchConnectivityManager.sharedConnectivityManager.delegate = self
        
        updateUI()
    }

    override func didDeactivate() {

        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        LogManager.display(forTypes: [.LifeCycle])
    }

}
