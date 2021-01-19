//
//  TimeRemainingView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import AppKit

class TimeRemainingView : NSView /*ContentAwareView*/ {
    
    private var fireDate: Date?
    var outOfRangeString: String = ""
    var prefixString: String = ""
    var showSecondsWithMinutes: Bool = false
    
    private var completion: (() -> Date?)?
    
    private weak var timer: Timer?
    
    lazy var label: NSTextField = {
        let view = NSTextField()
        view.isSelectable = false
        view.alignment = .center
        view.backgroundColor = NSColor.clear
        view.textColor = Theme(for: self).secondaryLabelColor
        view.font = NSFont.systemFont(ofSize: 14.0)
        view.isBordered = false
        view.drawsBackground = false
        return view
    }()
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBlurView() {
        self.layer?.backgroundColor = NSColor.clear.cgColor
//        let visualEffect = Theme(for: self).blurEffect

//        let visualEffectView = UIVisualEffectView(effect: visualEffect)

        let visualEffectView = NSVisualEffectView(frame: CGRect.zero)
        visualEffectView.material = .headerView
        
        if self.subviews.count > 0 {
            self.addSubview(visualEffectView, positioned: .below, relativeTo: self.subviews[0])
        } else {
            self.addSubview(visualEffectView)
        }
//        insertSubview(visualEffectView, at: 0)

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: self.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func addLabel(labelVerticalOffset: CGFloat) {
        let view = self.label
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
//            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: labelVerticalOffset),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
//            view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            view.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
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
        self.label.stringValue = self.outOfRangeString
        
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
            self.label.stringValue = self.prefixString + countDown.displayString
        } else {
            self.stop()
        }
    }

    private func timerDidFire() {
        self.updateCountDown()
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()

        if self.superview == nil {
            self.stopTimer()
        }
    }
}

