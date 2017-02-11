//
//  TimerManager.swift
//

import UIKit

protocol TimerManagerDelegate: class {

    /**
     Implement this method to add specific functionality when a timer event has been fired
     */
    func timerUpdated()
    /**
     Implement this method to add specific functionality when a timer event has been stopped
     */
    func timerStopped()
    /**
     Implement this method to to add specific functionality when a timer event has been started
     */
    func timerStarted()
}

class TimerManager: NSObject {

    // --------------------------
    // MARK: - Public Interface
    // --------------------------
    
    /**
     Shared instance of the TimerManager class
     */
    static let sharedTimerManager = TimerManager() // singleton

    /**
     Set the *delegate* and conform to protocol *TimerManagerDelegate* to implement the following methods:
     
     - timerUpdated()
     - timerStopped()
     - timerStarted()
     
     */
    weak var delegate: TimerManagerDelegate?       // Protocol delegate
    
    /**
     Return the count value of the timer. Represent a value indicating how many time he timer has been fired since it started.
     */
    func counter() -> Int {
        return timerCounter
    }

    /**
     Return a boolean indicating whether the timer is started.
     */
    func isStarted() -> Bool {
        return started
    }

    /**
     Call this method to start the timer with a default time interval of 1 second.
     */
    func start() {
        start(interval: TimeInterval(1.0))
    }

    /**
     Call this method to start the timer with a specific time interval in seconds.
     
     ````
     let timerManager = TimerManager.sharedTimerManager
     timerManager.start(interval: 3.4)
     ````
     
     - parameter timerInterval: Time interval in seconds
     */
    
    func start(interval timerInterval: Seconds) {

        started = true
        
        delegate?.timerStarted() // inform delegate of start timer
        
        // Start the timer schedule, if not yet started.
        if !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        }

    }

    /**
     Call this method to reset the count value of the timer and to stop it.
     */
    func reset() {

        timerCounter = 0

        stop()        
        
    }

    /**
     Call this method to stop the timer.
     
     - Note: This method does not reset the count value of the timer.
     */
    func stop() {
        
        started = false
        
        delegate?.timerStopped() // inform delegate of stop timer

        timer.invalidate()

    }
    
    /**
     Call this method to fire the timer once. It will then execute the completionHandler at the end of the specified timer duration
     
     ````
     let savedText = self.label.text
     self.label.text = "not available"
     TimerManager.singleTimer(withDuration: 3.0, completionHandler: {
        // set back the original text and color
        self.label.text = savedText
     })
     ````
     
     - parameter duration: timer event duration in seconds
     - parameter completionHandler: function called at the end of timer duration
     */
    static func singleTimer(withDuration duration: Seconds, completionHandler: @escaping () -> Void) {
        
        if !self.singleTimerRunning {
            self.singleTimerRunning = true
            LogManager.display(message: "singleTimer Started", forTypes: [.Flow])
            Timer.scheduledTimer(withTimeInterval:TimeInterval(duration), repeats: false, block: { _ in
                LogManager.display(message: "singleTimer Completed", forTypes: [.Flow])
                completionHandler()
                self.singleTimerRunning = false
            })
        }
        
    }
    
    // --------------------------
    // MARK: - Private Properties
    // --------------------------

    private var timer = Timer()
    
    private static var singleTimerRunning = false
    
    // timer information
    private var timerCounter = 0
    private var started = false
    
    // ---------------------------
    // MARK: - Convenience Methods
    // ---------------------------
    
    func timerFired() { // it's private, but needs to be visible so the timer object can use it
        
        timerCounter += 1
        delegate?.timerUpdated() // inform delegate of fired timer event
        
    }
    
}
