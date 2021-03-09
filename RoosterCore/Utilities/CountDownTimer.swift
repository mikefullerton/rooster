//
//  Date+TimeDisplayFormatter.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/7/21.
//

import Foundation

public protocol CountDownDelegate: AnyObject {
    func countdown(_ countDown: CountDownTimer, didUpdate displayString: String)
    func countdown(_ countDown: CountDownTimer, didFinish displayString: String)
    func countdownDisplayFormatter(_ countDown: CountDownTimer) -> TimeDisplayFormatter
    func countdown(_ countDown: CountDownTimer, willStart: Bool)
}

public class CountDownTimer: Loggable {
    public weak var delegate: CountDownDelegate?

    private let timer = SimpleTimer(withName: "CountDown")

    public var isCountingDown: Bool {
        self.timer.isTiming
    }

    public init() {
    }

    public init(withDelegate delegate: CountDownDelegate) {
        self.delegate = delegate
    }

    private var displayFormatter: TimeDisplayFormatter {
        if let delegate = self.delegate {
            return delegate.countdownDisplayFormatter(self)
        }

        return TerseTimeDisplayFormatter(showSecondsWithMinutes: 2)
    }

//    public var displayString: String {
//        return self.displayFormatter.displayString(withIntervalUntilFire: self.intervalUntilFire)
//    }

//    public var intervalUntilFire: TimeInterval {
//        if self.fireDate == nil {
//            return -1
//        }
//
//        return self.intervalUntilFireDate(self.fireDate!)
//    }

    private func intervalUntilFireDate(_ fireDate: Date) -> TimeInterval {
        Date().interval(toFutureDate: fireDate)
    }

    public func update(withFireDate fireDate: Date) {
        self.timer.stop()

        defer {
            if !self.timer.isTiming {
                self.stop()
            }
        }

        if let delegate = self.delegate {
            let interval = self.intervalUntilFireDate(fireDate)
            if interval > 0 {
                if !self.isCountingDown {
                    delegate.countdown(self, willStart: true)
                }

                let displayString = self.displayFormatter.displayString(withIntervalUntilFire: interval)

                delegate.countdown(self, didUpdate: displayString)

                // this will be either 1 minute or 1 second
                if let date = self.calculateNextTimerFireDate(withFireDate: fireDate) {
                    if date.isEqualToOrBeforeDate(Date()) {
                        self.logger.error("Calculated invalid fire date: \(date.shortDateAndLongTimeString)")
                    } else {
                        self.timer.start(withDate: date) { [weak self] _ in
                            self?.update(withFireDate: fireDate)
                        }
                    }
                }
            }
        }
    }

    private func calculateNextTimerFireDate(withFireDate fireDate: Date) -> Date? {
        let fastInterval = self.displayFormatter.showSecondsWithMinutes * 60

        let fastFireTime = fireDate.addingTimeInterval( -fastInterval )
        let now = Date()

        if fastFireTime.isEqualToOrBeforeDate(now) {
            return now.addSeconds(1)
        }

        let futureDate = now.addMinutes(1)
        return futureDate.removeSeconds
    }

    public func start(withFireDate fireDate: Date) {
        self.stop()

        if !self.isCountingDown {
            self.update(withFireDate: fireDate)
        } else {
            if self.isCountingDown {
                self.delegate?.countdown(self, willStart: false)
            }
        }
    }

    public func stop() {
        if self.isCountingDown {
            self.timer.stop()
            self.delegate?.countdown(self, didFinish: "")
        }
    }
}
