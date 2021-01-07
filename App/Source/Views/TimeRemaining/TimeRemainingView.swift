//
//  TimeRemainingView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

class TimeRemainingView : UILabel {
    
    private var fireDate: Date?
    var outOfRangeString: String = ""
    var prefixString: String = ""
    var showSecondsWithMinutes: Bool = false
    
    private var completion: (() -> Date?)?
    
    private weak var timer: Timer?
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startTimer(fireDate: Date?,
                    completion: (() -> Date? )? = nil) {
        
        self.completion = completion
        self.fireDate = fireDate
        self.stopTimer()

        if self.fireDate != nil {
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                self.timerDidFire()
            }
            self.timer = timer
            self.updateCountDown()
        } else {
            self.stop()
        }
    }
    
    func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        
        self.completion = nil
    }
    
    private func printableTimeComponent(interval: Double) -> String {
        return "\(Int(interval))"
//        let intValue: Int = Int(interval)
//        return intValue < 10 ? "0\(intValue)" : "\(intValue)"
    }
    
    private func stop() {
        self.stopTimer()
        self.text = self.outOfRangeString
        
        if let completion = self.completion {
            self.completion = nil
            
            if let nextDate = self.completion!() {
                self.startTimer(fireDate: nextDate, completion: completion)
            }
        }
    }

    #if targetEnvironment(macCatalyst)
    let hours = " hours"
    let minutes = " minutes"
    let seconds = " seconds"
    #else
    let hours = "h"
    let minutes = "m"
    let seconds = "s"
    #endif
    
    private func updateCountDown() {

        guard let fireDate = self.fireDate else {
            self.stop()
            return
        }
        
        let countDown = CountDown(withFireDate: fireDate,
                                  formatter: LongCountDownStringFormatter(),
                                  showSecondsWithMinutes: self.showSecondsWithMinutes)
        
        
//        let fireTime = fireDate.timeIntervalSinceReferenceDate
//        let nowInterval = Date().timeIntervalSinceReferenceDate
//        let interval = fireTime - nowInterval

        if countDown.intervalUntilFire > 0 {

//            let minutes = interval / (60.0)
//
//            let hours = floor(interval / (60.0 * 60.0))
//
//            let displayMinutes = floor((interval - (hours * 60 * 60)) / 60)
//            let displaySeconds = interval - (hours * 60 * 60) - (floor(minutes) * 60)
//
//            var shouldDisplaySeconds = false
//            var text = ""
//            if hours > 0 {
//                text += "\(self.printableTimeComponent(interval: hours))\(self.hours)"
//                if displayMinutes > 1 {
//                    text += ", \(self.printableTimeComponent(interval: displayMinutes))\(self.minutes)"
//                } else if displayMinutes == 1 {
//                    text += ", 1 minute"
//                }
//            } else if displayMinutes == 1 {
//                text += "1 minute"
//            } else if displayMinutes > 0 {
//                text += "\(self.printableTimeComponent(interval: displayMinutes))\(self.minutes)"
//                shouldDisplaySeconds = self.showSecondsWithMinutes
//
//                if shouldDisplaySeconds {
//                    text += ", "
//                }
//            } else {
//                shouldDisplaySeconds = true
//            }
//
//            if shouldDisplaySeconds {
//                if displaySeconds > 1 {
//                    text += "\(self.printableTimeComponent(interval: displaySeconds))\(self.seconds)"
//                } else if displaySeconds == 1 {
//                    text += "1 second"
//                } else {
//                    text += "0 seconds"
//                }
//            }

            self.text = self.prefixString + countDown.displayString
        } else {
            self.stop()
        }
    }

    private func timerDidFire() {
        self.updateCountDown()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if self.superview == nil {
            self.stopTimer()
        }
    }
}

class TimeRemainingView_iOS : TimeRemainingView, DataModelAware {
    
    private var reloader: DataModelReloader? = nil

    func startTimer() {
    
        if self.reloader == nil {
            self.reloader = DataModelReloader(for: self)
        
            self.prefixString = "Next alarm in "
            self.showSecondsWithMinutes = true
            self.outOfRangeString = "No more meetings today! 🎉"
        }

        self.startTimer(fireDate: DataModelController.instance.dataModel.nextAlarmDate) { () -> Date? in
            return DataModelController.instance.dataModel.nextAlarmDate
        }
    }
    
    func dataModelDidReload(_ dataModel: DataModel) {
        self.startTimer()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if self.superview != nil {
            self.startTimer()
        }
    }
}
