//
//  IPhoneTestController.swift
//

import UIKit

class IPhoneTestController: UIViewController, TimerManagerDelegate, WatchConnectivityManagerPhoneDelegate {

    // --------------------------
    // MARK: - Outlets
    // --------------------------

    @IBOutlet weak var watchCounterLabel: UILabel!
    @IBOutlet weak var iPhoneCounterLabel: UILabel!
    @IBOutlet weak var startStopIPhoneButtonLabel: UIButton!
    @IBOutlet weak var startStopWatchButtonLabel: UIButton!
    @IBOutlet weak var watchMessageLabel: UILabel!

    // --------------------------
    // MARK: - Actions
    // --------------------------

    @IBAction func startStopIPhoneButton(_ sender: UIButton) {
        
        LogManager.display(forTypes: [.UserAction])
        
        self.startStopIPhoneButtonLabel.setTitle("Wait", for: .normal)
        
        if buttonIPhoneStatus == .Stopped {
            timerManager.start(interval: timerInterval)
            _ = WatchConnectivityManager.sendMessage(["Start" : DeviceID.iPhone])
        } else {
            timerManager.stop()
            _ = WatchConnectivityManager.sendMessage(["Stop" : DeviceID.iPhone])
        }
    }

    @IBAction func startStopWatchButton(_ sender: UIButton) {
        
        LogManager.display(forTypes: [.UserAction])
        
        self.startStopWatchButtonLabel.setTitle("Wait", for: .normal)
        
        if buttonWatchStatus == .Stopped {
            if WatchConnectivityManager.sendMessage(["Start" : DeviceID.watch]) == false {
                // Watch app is not started, so the timer won't start either: send a warning message
                buttonWatchStatus = .Stopped
                let savedText = self.watchMessageLabel.text
                let savedColor = self.watchMessageLabel.textColor
                watchMessageLabel.text = "not available"
                watchMessageLabel.textColor = #colorLiteral(red: 0.7686850429, green: 0.13597399, blue: 0.04272824526, alpha: 1)
                TimerManager.singleTimer(withDuration: 1.0, completionHandler: {
                    // set back the original text and color
                    self.watchMessageLabel.text = savedText
                    self.watchMessageLabel.textColor = savedColor
                })
            }
        } else {
            if WatchConnectivityManager.sendMessage(["Stop" : DeviceID.watch]) == false {
                buttonWatchStatus = .Started
            }
        }
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        
        LogManager.display(forTypes: [.UserAction])
        
        self.startStopIPhoneButtonLabel.setTitle("Wait", for: .normal)
        self.startStopWatchButtonLabel.setTitle("Wait", for: .normal)
        
        // Stop and reset all counters
        timerManager.reset()
        _ = WatchConnectivityManager.sendMessage(["Stop" : DeviceID.iPhone])
        if WatchConnectivityManager.sendMessage(["Reset" : DeviceID.watch]) == false {
            // Watch app is not started, so the timer won't reset either
            buttonWatchStatus = .Stopped
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
                    self.startStopIPhoneButtonLabel.setTitle("Stop", for: .normal)
                } else {
                    self.startStopIPhoneButtonLabel.setTitle("Start", for: .normal)
                }
            }
        }
    }
    var buttonWatchStatus: ButtonStatus = .Stopped {
        willSet {
            DispatchQueue.main.async { // this is needed as the setting comes from Watch
                // set button label accordingly
                if newValue == .Started {
                    self.startStopWatchButtonLabel.setTitle("Stop", for: .normal)
                } else {
                    self.startStopWatchButtonLabel.setTitle("Start", for: .normal)
                }
            }
        }
    }
    
    func updateUI() {

        // display counters value
        
        let counter = timerManager.counter()
        iPhoneCounterLabel.text = "\(counter)"

        // set button label accordingly
        
        if timerManager.isStarted() {
            buttonIPhoneStatus = .Started
        } else {
            buttonIPhoneStatus = .Stopped
        }
        
        LogManager.display(message: "Timer iPhone is \(buttonIPhoneStatus.rawValue). Current count is \(counter)", forTypes: [.Debug])

        DispatchQueue.main.async { // this needs to be run on main queue to work
            // Send counter value to connected device
            _ = WatchConnectivityManager.sendMessage(["Timer" : DeviceID.iPhone, "Counter": counter])
        }

        
    }
    
    // --------------------------
    // MARK: - Implement protocol
    // --------------------------
    
    func timerUpdated() {
        
        LogManager.display(forTypes: [.Flow])
        LogManager.display(message: "Timer Count updated for device iPhone", forTypes: [.Debug])
        
        updateUI()
    }
    
    func timerStopped() {

        LogManager.display(forTypes: [.Flow])
        LogManager.display(message: "Timer Stopped for device iPhone", forTypes: [.Debug])
        
        updateUI()

    }
    
    func timerStarted() {
       
        LogManager.display(forTypes: [.Flow])
        LogManager.display(message: "Timer Started for device iPhone", forTypes: [.Debug])
        
        updateUI()
        
    }
    
    // --------------------------------------------
    // MARK: - Implement WatchConnectivity protocol
    // --------------------------------------------
    
    func didReceive(message: [String : Any]) {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        LogManager.display(message: "Reveiced message: \(message)", forTypes: [.Debug,.WatchConnection])
        
        if let device = message["Start"] as? String {
            
            if device == DeviceID.iPhone {
                
                // an external request has been received to start the watch timer
                buttonIPhoneStatus = .Started
                DispatchQueue.main.async { // this is needed as the request comes from another device (being a background task not running on main queue)
                    self.timerManager.start(interval: timerInterval)
                }

                // Inform requester that we actually started the timer
                _ = WatchConnectivityManager.sendMessage(["Start" : DeviceID.iPhone])
                
            } else if device == DeviceID.watch {
                
                // an external device has started its timer, reflect the change here
                buttonWatchStatus = .Started
                
            }
            
        } else if let device = message["Stop"] as? String {
            
            if device == DeviceID.iPhone {
                
                // an external request has been received to stop the watch timer
                buttonIPhoneStatus = .Stopped
                DispatchQueue.main.async { // this is needed as the request comes from another device (being a background task not running on main queue)
                    self.timerManager.stop()
                }
                
                // Inform requester that we actually started the timer
                _ = WatchConnectivityManager.sendMessage(["Stop" : DeviceID.iPhone])
                
            } else if device == DeviceID.watch {
                
                // an external device has stopped its timer, reflect the change here
                buttonWatchStatus = .Stopped
                
            }

        } else if let device = message["Timer"] as? String {
            
            if device == DeviceID.watch {
                
                // we received a request to reflect our UI from processing of an external device
                // this needs to be done on the main thread as the request start from a background process
                
                if let counter = message["Counter"] as? Int {
                    
                    // update counter of connected device
                    
                    DispatchQueue.main.async {
                        self.watchCounterLabel.text = "\(counter)"

                    }
                    
                }
                
            }
            
        }
        
    }
    
    // --------------------------
    // MARK: - Life cycle
    // --------------------------
    
    override func viewDidLoad() {
        
        LogManager.display(forTypes: [.LifeCycle])
        
        super.viewDidLoad()

        timerManager.delegate = self
        WatchConnectivityManager.sharedConnectivityManager.delegate = self
        
        updateUI()
        
    }
    
    
}
