//
//  CountDownTextField.swift
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

public protocol CountDownTextFieldDelegate : AnyObject {
    func countDownTextFieldNextFireDate(_ countDownTextField: CountDownTextField) -> Date?
}

open class CountDownTextField : SDKTextField, CountDownDelegate {
    
    public static let showSecondsDefault = 2.0
    
    private lazy var countDown = CountDownTimer(withDelegate: self)

    public var outOfRangeString: String = ""
    
    public weak var countDownDelegate: CountDownTextFieldDelegate?
    
    public var prefixString: String = "" {
        didSet {
            self.countDown.update()
        }
    }

    public var showSecondsWithMinutes: TimeInterval = CountDownTextField.showSecondsDefault {
        didSet {
            self.countDown.update()
        }
    }

    public var outputFormatter: ((_ prefix: String, _ countdownString: String) -> String)?
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.configure()
    }
    
    public required init?(coder: NSCoder) {
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

    open func startCountDown() {
        self.countDown.start()
    }

    open func stopCountDown() {
        self.countDown.stop()
        self.stringValue = ""
    }
    
    private func countDownFinished() {
        self.stringValue = self.outOfRangeString
        self.countDown.start()
    }
   
    open func countdown(_ countDown: CountDownTimer, willStart: Bool) {
        if !willStart {
            self.stringValue = self.outOfRangeString
        }
    }
    
    open func countdown(_ countDown: CountDownTimer, didUpdate displayString: String) {
        if let outputFormatter = self.outputFormatter {
            self.stringValue = outputFormatter(self.prefixString, displayString)
        } else {
            self.stringValue = self.prefixString + displayString
        }
    }
    
    open func countdownFireDate(_ countDown: CountDownTimer) -> Date? {
        
        // stop if we're hidden
        if self.isHidden {
            self.stopCountDown()
            return nil
        }
        
        if let delegate = self.countDownDelegate {
            return delegate.countDownTextFieldNextFireDate(self)
        }
        return nil
    }

    open func countdownDisplayFormatter(_ countDown: CountDownTimer) -> TimeDisplayFormatter {
        return VerboseTimeDisplayFormatter(showSecondsWithMinutes: self.showSecondsWithMinutes)
    }
    
    open func countdown(_ countDown: CountDownTimer, didFinish displayString: String) {
        self.countDownFinished()
    }
    
    open override func viewWillMove(toWindow window: NSWindow?) {
        super.viewWillMove(toWindow: window)

        if window == nil {
            self.stopCountDown()
        }
    }

}
