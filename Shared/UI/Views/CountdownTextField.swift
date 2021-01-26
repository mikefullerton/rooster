//
//  CountdownTextField.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/20/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class CountdownTextField : SDKTextField {
    
    private var fireDate: Date?
    var outOfRangeString: String = ""
    var prefixString: String = "" {
        didSet {
            self.updateCountDown()
        }
    }
    var showSecondsWithMinutes: Bool = false

    private var completion: (() -> Date?)?
    
    private let timer = SimpleTimer(withName: "CountdownTextField")

    var outputFormatter: ((_ prefix: String, _ countdownString: String) -> String)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    private func configure() {
        self.isSelectable = false
        self.alignment = .center
        self.backgroundColor = SDKColor.clear
        self.textColor = Theme(for: self).secondaryLabelColor
        self.isBordered = false
        self.drawsBackground = false
        self.isEditable = false
    }
    
    func startTimer(fireDate: Date?,
                    completion: (() -> Date? )? = nil) {
        
        self.completion = completion
        self.fireDate = fireDate
        self.stopTimer()

        if self.fireDate != nil {
            self.timer.start(withDate: fireDate!) { [weak self] timer in
                self?.timerDidFire()
            }
            
            self.updateCountDown()
        } else {
            self.stopCountdown()
        }
    }
    
    private func stopTimer() {
        self.timer.stop()
        self.completion = nil
    }
    
    func stopCountdown() {
        self.stopTimer()
        self.stringValue = ""
    }
    
    func countDownFinished() {
        self.stopTimer()
        self.stringValue = self.outOfRangeString
        
        if let completion = self.completion {
            self.completion = nil
            
            if  let nextDate = completion() {
                self.startTimer(fireDate: nextDate, completion: completion)
            }
        }
    }
    
    private func updateCountDown() {
       guard let fireDate = self.fireDate else {
            self.stopCountdown()
            return
        }
        
        let countDown = CountDown(withFireDate: fireDate,
                                  formatter: LongCountDownStringFormatter(),
                                  showSecondsWithMinutes: self.showSecondsWithMinutes)
        
        if countDown.intervalUntilFire > 0 {
            if let outputFormatter = self.outputFormatter {
                self.stringValue = outputFormatter(self.prefixString, countDown.displayString)
            } else {
                self.stringValue = self.prefixString + countDown.displayString
            }
        } else {
            self.countDownFinished()
        }
    }

    private func timerDidFire() {
        self.updateCountDown()
    }
    
    override func viewWillMove(toWindow window: NSWindow?) {
        super.viewWillMove(toWindow: window)

        if window == nil {
            self.stopTimer()
        }
    }
}
