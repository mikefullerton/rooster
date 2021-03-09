//
//  TimePassView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/25/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class TimePassingView: SDKView {
    var dateRange: DateRange? {
        didSet {
            if self.dateRange != oldValue {
                self.needsLayout = true
                self.startTimer()
            }
        }
    }

    private let timer = SimpleTimer(withName: "TimePassingViewTimer")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.addIndicatorView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    lazy var indicatorView = TimePassingIndicatorView()

    func addIndicatorView() {
        self.addSubview(self.indicatorView)

        self.needsLayout = true
    }

    override public func layout() {
        super.layout()

        self.updateIndicator()
    }

    private func updateIndicator() {
        let now = Date()

        if let dateRange = self.dateRange, dateRange.isHappeningNow {
            let totalMinutes = dateRange.endDate.timeIntervalSince(dateRange.startDate) / 60
            let remainingMinutes = dateRange.endDate.timeIntervalSince(now) / 60

            let height = TimeInterval(self.bounds.size.height)

            let pointsPerMinute = height / totalMinutes

            let remainingHeight = CGFloat(remainingMinutes * pointsPerMinute)

            let indicatorFrame = CGRect(x: 0,
                                        y: remainingHeight - (self.indicatorView.height / 2),
                                        width: self.bounds.size.width,
                                        height: self.indicatorView.height)

            self.indicatorView.frame = indicatorFrame
            self.indicatorView.isHidden = false
        } else {
            self.indicatorView.isHidden = true
        }
    }

    private func startTimer() {
        self.needsLayout = true

        if let dateRange = self.dateRange, dateRange.isHappeningNow {
            let date = Date().addingTimeInterval(60).removeSeconds

            self.timer.start(withDate: date,
                             interval: 60,
                             fireCount: SimpleTimer.RepeatEndlessly) { [weak self] _ in
                self?.needsLayout = true
            }
        }
    }

    func stopTimer() {
        self.dateRange = nil
        self.needsLayout = true
        self.timer.stop()
    }

    override public func viewWillMove(toWindow window: NSWindow?) {
        super.viewWillMove(toWindow: window)

        if window == nil {
            self.stopTimer()
        }
    }
}
