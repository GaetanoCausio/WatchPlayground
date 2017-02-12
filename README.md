# WatchPlayground

[![Shippable](https://img.shields.io/badge/platform-iOS%20%7C%20WatchOS-lightgrey.svg)]()
[![Shippable](https://img.shields.io/badge/language-swift-orange.svg)]()
[![Shippable](https://img.shields.io/badge/build-passing-green.svg)]()
[![Shippable](https://img.shields.io/badge/tests-passing-green.svg)]()
[![Shippable](https://img.shields.io/badge/license-apache%202.0-blue.svg)]()

A sample project that demonstrate the bidirectional connectivity interactions between an iPhone and an Apple Watch.   

Tests on real devices are preferred. Have a look at file *UITESTS.md*, you'll find detail instructions on how to perform UI Tests and so verify that the code is properly working. By the way, any suggestion/tools on how to perform automatic UI Tests on Apple Watch connectivity with an iPhone are most than welcome!

For the connectivity I used the *sendMessage* and *didReceiveMessage* methods of the WCSession class, as these methods are most suitable for immediate communication.

Please note that the *sendMessage* method is executed asynchronously on a background thread, so if you need to update the UI as a result of this method then you need to work on the Main thread.

## Usage
Open the project in Xcode, eventually specify the logging levels in file *LogManager.swift* class, then build and run on an Apple Watch paired with an iPhone.

## What's Next
Implementation of a better design architecture: Model-View-ViewModel (MVVM) in combination of Protocol Oriented Programming (POP) .

<BR>    
---
*A continuos learning path where passion is the drive.*

