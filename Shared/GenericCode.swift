//
//  GenericCode.swift
//

import Foundation

// Handy Constants

enum ButtonStatus : String {
    case Started, Stopped
}

struct DeviceID {
    static let iPhone = "iPhone"
    static let watch = "Watch"
}

// Handy aliasses

typealias Seconds = Double

// Functional Parameters

let timerInterval = TimeInterval(1.5)
