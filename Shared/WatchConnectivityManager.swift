//
//  WatchConnectivityManager.swift
//

import WatchConnectivity

protocol WatchConnectivityManagerPhoneDelegate: class {
    /**
     Implement this method to add specific functionality when a message is received from a Watch
    */
    func didReceive(message: [String : Any])
}

protocol WatchConnectivityManagerWatchDelegate: class {
    /**
     Implement this method to add specific functionality when a message is received from a iPhone
     */
    func didReceive(message: [String : Any])
}

class WatchConnectivityManager: NSObject, WCSessionDelegate {

    // --------------------------
    // MARK: - Public Interface
    // --------------------------

    /**
     Shared instance of the WatchConnectivityManager class
     */
    static let sharedConnectivityManager = WatchConnectivityManager()

    
    #if os(iOS) // let's keep it generic for now, in case in the future we add more specific functionality
    /**
     Set the *delegate* and conform to protocol *WatchConnectivityManagerPhoneDelegate* to implement the following methods:
     
     - didReceive(message:)
     
     */
    weak var delegate: WatchConnectivityManagerPhoneDelegate?
    static let currentDevice = DeviceID.iPhone
    static let targetDevice = DeviceID.watch
    #else
    /**
     Set the *delegate* and conform to protocol *WatchConnectivityManagerWatchDelegate* to implement the following methods:
     
     - didReceive(message:)
     
     */
    weak var delegate: WatchConnectivityManagerWatchDelegate?
    static let currentDevice = DeviceID.watch
    static let targetDevice = DeviceID.iPhone
    #endif
    
    
    /**
     Send a data message to the counterpart
     - parameter message: a dictionary containing the information to send
    */
    
    static func sendMessage(_ message: [String: Any]) -> Bool {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        
        if WCSession.isSupported() {

            let session = WCSession.default()
        
            LogManager.debugWatchSession(session)

            if session.isReachable {
                
                LogManager.display(message: "Sending message to \(targetDevice): \(message)", forTypes: [.Debug,.WatchConnection])
                
                DispatchQueue.main.async { // this needs to be run on main queue to work
                    session.sendMessage(message, replyHandler: nil, errorHandler:  { error in
                        LogManager.display(message: "Error sending message to \(targetDevice). Message: \(message). Error: \(error.localizedDescription)", forTypes: [.Error,.WatchConnection])
                    })
                }
                
                return true
            }
            
        }
        
        LogManager.display(message: "No Watch Connection Session available.", forTypes: [.Debug,.WatchConnection])
        
        return false
        
    }

    // ------------------------------
    // MARK: - Private Implementation
    // ------------------------------
    
    private override init() {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        
        super.init()
        
    }
    

    // ----------------------------------
    // MARK: - WCSession Delegate methods
    // ----------------------------------

    // The next method is required in order to support asynchronous session activation as well as for quick watch switching.
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        
        if let error = error {
            LogManager.display(message: "session activation failed with error: \(error.localizedDescription)", forTypes: [.Error])
            return
        }
        
        LogManager.display(message: "session activated with state: \(activationState.rawValue)", forTypes: [.Debug])
        
        if activationState == .activated {
            LogManager.display(message: "activationState: Activated", forTypes: [.Debug] )
        }
        if activationState == .inactive {
            LogManager.display(message: "activationState: Inactive", forTypes: [.Debug])
        }
        if activationState == .notActivated {
            LogManager.display(message: "activationState: NotActivated", forTypes: [.Debug])
        }

        LogManager.debugWatchSession(session)
    }
    
    #if os(iOS)
    // The next 2 methods are required in order to support quick watch switching.
    func sessionDidBecomeInactive(_ session: WCSession) {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        
        /*
         The `sessionDidBecomeInactive(_:)` callback indicates sending has been disabled. If your iOS app
         sends content to its Watch extension it will need to stop trying at this point. This sample
         doesn’t send content to its Watch Extension so no action is required for this transition.
         */
        
        LogManager.debugWatchSession(session)
        

    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        
        /*
         The `sessionDidDeactivate(_:)` callback indicates `WCSession` is finished delivering content to
         the iOS app. iOS apps that process content delivered from their Watch Extension should finish
         processing that content and call `activateSession()`. This sample immediately calls
         `activateSession()` as the data provided by the Watch Extension is handled immediately.
         */
        LogManager.debugWatchSession(session)
        
        session.activate()
        
        LogManager.debugWatchSession(session)
        
    }
    #endif

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {

        LogManager.display(forTypes: [.Flow,.WatchConnection])
        
        // Inform the delegate.
        delegate?.didReceive(message: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        
        // Inform the delegate.
        // delegate?.watchConnectivityManager(self, updatedWithDesignator: "-", designatorColor: "Blue")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        
        #if os(iOS)
            // Inform the delegate.
            // delegate?.watchConnectivityManager(self, updatedWithDesignator: "-", designatorColor: "Blue")
        #endif
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        
        #if os(watchOS)
            // Inform the delegate.
            // delegate?.watchConnectivityManager(self, updatedWithMorseCode: morseCode)
        #endif
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        
        LogManager.display(forTypes: [.Flow,.WatchConnection])
        
        if let error = error {
            LogManager.display(message: "\(error.localizedDescription)", forTypes: [.Error])
        } else {
            LogManager.display(message: "completed transfer of \(userInfoTransfer)", forTypes: [.Debug])
        }
    }
    
}
