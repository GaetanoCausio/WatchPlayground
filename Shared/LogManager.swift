//
//  LogManager.swift
//

import Foundation
import WatchConnectivity

/**
 Log categorization. Allows you to show/hide each log type indipendetly so to focus only on specific logging.
 
 Flow type message logs:
 - LifeCycle : *Used for Life Cycle methods as viewDidLoad*
 - Flow : *Used at the beginning of a method or function*
 - UserAction : *Used at the beginning of a IBAction method*

 Informational type message logs:
 - Data : *Used whener you have to display data content*
 - Debug : *Used for any informational or debug messages*
 - Error : *Used when an error occurs*
 
 Functional type message logs:
 - WatchConnection : *Functionality is related to Watch Connectivity*
 - LocationServices : *Functionality is related to Location Services*

 
*/
enum LogType : String {
    case Flow, Data, Error, Debug, UserAction, LifeCycle, WatchConnection, LocationServices
}

/** Manage all loggings for your appliction.
 
 - Manually enable/disable specific logging types
 - Logging disabled for Release distribution
 
 */

class LogManager: NSObject {

    // ----------------------
    // MARK: - Logging Levels
    // ----------------------

    // Set following log parameters as needed:
    
    private static let displayFlow = false
    private static let displayData = false
    private static let displayDebug = false
    private static let displayAction = false
    private static let displayLifeCycle = false
    private static let displayWatchConnection = false
    private static let displayLocationServices = false

    // --------------------------
    // MARK: - Private Variables
    // --------------------------

    private static var isLoggingForDistributionChecked = false
    
    // --------------------------
    // MARK: - Public Interface
    // --------------------------
    
    /**
     Output a log message to console of a specific type.
          
     You can send a message to the log and assign it to one or more log types. You can then set in the class *LogManager* which logging types you want to show.
     ````
     LogManager.display(message: "Result is \(result)", forTypes: [.Debug,.WatchConnection])
     ````
     For the following types you do not need to specify a message. The function name will be automatically displayed on the log.
     ````
     LogManager.display(forTypes: [.Flow])
     ````

     - Important: Please set the logging level in the LogManager class to enable logging.
     
     - Note: The following symbols are used when displaying the log message:
     
     - [F] = Flow type of log (incl. LifeCycle type)
     - [A] = Represents a log from a user action
     - [L] = Log related to Location Services
     - [L] = Log related to Watch Connectivity
     - [D] = Standard debug log message
     - [!] = Used for Error messages
     
     - parameter message: the message to be displayed on log
     - parameter logTypes: one of more category type for this log message
     - parameter file: do not use, automatically set
     - parameter function: do not use, automatically set
     - parameter line: do not use, automatically set
     
    */
    static func display(message: String = "", forTypes logTypes: Set<LogType>, file: String = #file, function: String = #function, line: Int = #line) {

        #if RELEASE
            return
        #endif
        
        var printMessage = false  // is the log message enabled for printing ?
        var showFlowInfo = false  // is it a flow type message?
        var logTypeSymbol = "[D]" // default symbols for log message
        
        for logType in logTypes {
            
            // Set symbol of log message
            
            if (logType == .LifeCycle) || (logType == .Flow || (logType == .UserAction) ) {
                showFlowInfo = true
                logTypeSymbol = "[F]"
                if logType == .UserAction { logTypeSymbol = "[A]" }
            } else {
                // Set debug symbol for log message
                if logType == .WatchConnection { logTypeSymbol = "[W]" }
                if logType == .LocationServices { logTypeSymbol = "[L]" }
                if logType == .Error { logTypeSymbol = "[!]" }
            }

            // is the log enabled for this type ?
            
            if logType == .Error { printMessage = true; break }
            if displayAction && logType == .UserAction { printMessage = true; break }
            if displayFlow && logType == .Flow { printMessage = true; break }
            if displayDebug && logType == .Debug { printMessage = true; break }
            if displayData && logType == .Data { printMessage = true; break }
            if displayLifeCycle && logType == .LifeCycle { printMessage = true; break }
            if displayWatchConnection && logType == .WatchConnection { printMessage = true; break }
            if displayLocationServices && logType == .LocationServices { printMessage = true; break }
            
        }
        
        // Print log message if enabled
        
        if printMessage {
            if showFlowInfo {
                let fileName = (file as NSString).lastPathComponent
                let logSign:String
                if logTypeSymbol == "[A]" { logSign = "$" } else {logSign = "*"}
                NSLog("%@ %@ [%@:%d] - %@ %@",logTypeSymbol,logSign,fileName, line, function, message) // NSLog output also to console, print() does not !
            } else {
                NSLog("%@ - %@",logTypeSymbol,message) // NSLog output also to console, print() does not !
            }
        }
        
    }

    /**
     Log specific Watch Connectivity session data.
     
     ````
      LogManager.debugWatchSession(session)
     ````
     - Important: Please set the logging level in the LogManager class to enable logging.
     
     - parameter session: watch connectivty session object
     - parameter file: do not use, automatically set
     - parameter function: do not use, automatically set
     - parameter line: do not use, automatically set
    
    */
    static func debugWatchSession(_ session: WCSession, file: String = #file, function: String = #function, line: Int = #line) {
        
        #if RELEASE
            return
        #endif
        
        LogManager.display(message: "WC isSupported=\(WCSession.isSupported())", forTypes: [.Data,.WatchConnection], file: file, function: function, line: line)
        LogManager.display(message: "WC isReachable=\(session.isReachable)", forTypes: [.Data,.WatchConnection], file: file, function: function, line: line)

        // `watchDirectoryURL` is only available on iOS and this class is used on both platforms.
        #if os(iOS)
            LogManager.display(message: "WC isPaired=\(session.isPaired)", forTypes: [.Data,.WatchConnection], file: file, function: function, line: line)
            LogManager.display(message: "WC isWatchAppInstalled=\(session.isWatchAppInstalled)", forTypes: [.Data,.WatchConnection], file: file, function: function, line: line)
            LogManager.display(message: "WC watchDirectoryURL=\(String(describing: session.watchDirectoryURL))", forTypes: [.Data,.WatchConnection], file: file, function: function, line: line)
        #endif

        if session.activationState == .activated {
            LogManager.display(message: "WC activationState: Activated", forTypes: [.Data,.WatchConnection], file: file, function: function, line: line )
        }
        if session.activationState == .inactive {
            LogManager.display(message: "WC activationState: Inactive", forTypes: [.Data,.WatchConnection], file: file, function: function, line: line)
        }
        if session.activationState == .notActivated {
            LogManager.display(message: "WC activationState: NotActivated", forTypes: [.Data,.WatchConnection], file: file, function: function, line: line)
        }

        
    }
    
    
}
