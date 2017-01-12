//
//  YHCountDownTimer.swift
//  OMNI_ComponentA
//
//  Created by Yilei He on 1/08/2016.
//  Copyright © 2016 lionhylra.com. All rights reserved.
//

import UIKit

let YHTimerReadChangedNotification = "YHCountDownTimer.ReadChanged.Notification"
let YHTimerTimeLeftKey = "YHCountDownTimer.TimeLeft"
let YHTimerInitialTimeKey = "YHCountDownTimer.InitialTimer"



/**
    This is a timer that wraps NSTimer to provide functions like resume(), pause(), stop() and restart().
 
    You have two methods to subscribe the change of read: 
 
    - One method is to use NSNotification center to add your observer to noticiation "YHTimerReadChangedNotification". In the notification, the object is the YHCountDownTimer instance itself. You can get the time left from userInfo using key "YHTimerTimeLeftKey", and get the initial time using key "YHTimerInitialTimeKey".
 
    - The other method is to provide a subscription block in the initializer or set to the property "timeChangeHandler". The time left is passed in to the handler.
 */
class YHCountDownTimer: NSObject {
    var initialTime: TimeInterval
    var interval: TimeInterval
    var timeLeft: TimeInterval
    private weak var timer: Timer?
    private(set) var isFired: Bool = false
    var timeChangeHandler: ((TimeInterval) -> Void)?
    
    
    @discardableResult
    init(initialTime: TimeInterval, interval: TimeInterval = 1, fireImmediately: Bool = false, readDidChange: ((TimeInterval) -> Void)? = nil) {
        self.initialTime = initialTime
        self.interval = interval
        self.timeLeft = initialTime
        self.timeChangeHandler = readDidChange
        super.init()
        
        if fireImmediately { resume() }
    }
    
    
    
    /**
     Start the timer. If the timer is already started, this method does nothing.
     */
    func resume() {
        guard !isFired && timeLeft != 0 else {return}
        isFired = true
        //do initial time update
        timeChangeHandler?(timeLeft)
        NotificationCenter.default.post(name: Notification.Name(rawValue: YHTimerReadChangedNotification), object: self, userInfo: [YHTimerTimeLeftKey: timeLeft, YHTimerInitialTimeKey: initialTime])
        
        //start timer
        let timer = Timer(timeInterval: interval, target: self, selector: #selector(updateRead), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        self.timer = timer
    }
    
    
    
    /**
     Pause timer.
     */
    func pause() {
        isFired = false
        timer?.invalidate()
    }
    
    
    /**
     Stop timer. The time left will be set to 0. And a notification is sent with the read that is updated to 0.
     */
    func stop() {
        isFired = false
        timer?.invalidate()
        timeLeft = 0
        timeChangeHandler?(timeLeft)//using block
        NotificationCenter.default.post(name: Notification.Name(rawValue: YHTimerReadChangedNotification), object: self, userInfo: [YHTimerTimeLeftKey: timeLeft, YHTimerInitialTimeKey: initialTime])// using notification
    }
    
    
    
    /**
     Reset the timer and start it again. You can start the timer from the original initial time, or pass in a new initial time for starting.
     
     - parameter initialTime: A new initial time.
     */
    func restart(initialTime: TimeInterval? = nil) {
        if let initialTime = initialTime {
            self.initialTime = initialTime
        }
        timeLeft = self.initialTime
        resume()
    }
    
    
    
    @objc private func updateRead() {
        //validate time left
        timeLeft -= interval
        timeLeft = max(0, timeLeft)
        
        //trigger event
        timeChangeHandler?(timeLeft)//using block
        NotificationCenter.default.post(name: Notification.Name(rawValue: YHTimerReadChangedNotification), object: self, userInfo: [YHTimerTimeLeftKey: timeLeft, YHTimerInitialTimeKey: initialTime])// using notification
        
        //process last bit time left
        if timeLeft / interval <= 1 && timeLeft != 0 {
            self.timer?.invalidate()
            let timer = Timer(timeInterval: timeLeft, target: self, selector: #selector(updateRead), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
            self.timer = timer
        }
        
    }
}


