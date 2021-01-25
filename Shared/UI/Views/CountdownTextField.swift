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
    var prefixString: String = ""
    var showSecondsWithMinutes: Bool = false

    private var completion: (() -> Date?)?
    
    private weak var timer: Timer?

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
    
    private func stop() {
        self.stopTimer()
        self.stringValue = self.outOfRangeString
        
        if let completion = self.completion {
            self.completion = nil
            
            if let nextDate = self.completion!() {
                self.startTimer(fireDate: nextDate, completion: completion)
            }
        }
    }
    
    private func updateCountDown() {
       guard let fireDate = self.fireDate else {
            self.stop()
            return
        }
        
        let countDown = CountDown(withFireDate: fireDate,
                                  formatter: LongCountDownStringFormatter(),
                                  showSecondsWithMinutes: self.showSecondsWithMinutes)
        if countDown.intervalUntilFire > 0 {
            self.stringValue = self.prefixString + countDown.displayString
        } else {
            self.stop()
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
