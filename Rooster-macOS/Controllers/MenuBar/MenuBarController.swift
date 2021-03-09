//
//  MenubarPopover.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import AppKit
import Foundation
import RoosterCore

public class MenuBarController: Loggable {
    private var scheduleUpdateHandler = ScheduleUpdateHandler()

    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    private let deferred = DeferredCallback()

    let button = MenuBarButton()

    var prefs: MenuBarPreferences {
        AppControllers.shared.preferences.menuBar
    }

    private var alarmState: AlarmState = .none

    private lazy var countDown = CountDownTimer(withDelegate: self)

    private lazy var flashingTimer = SimpleTimer(withName: "flashing timer")

    var isAlarmFiring: Bool {
        CoreControllers.shared.alarmNotificationController.alarmsAreFiring
    }

    public init() {
        self.scheduleUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else { return }
            self.deferred.schedule { [weak self] in
                self?.updateAlarmState()
            }
        }

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else { return }
            self.deferred.schedule { [weak self] in
                guard let self = self else { return }

                self.button.isVisible = self.prefs.showInMenuBar
                self.updateAlarmState()
            }
        }
    }

    deinit {
        self.flashingTimer.stop()
        self.countDown.stop()
    }

    // MARK: - methods

    func showInMenuBar() {
        self.button.isVisible = self.prefs.showInMenuBar
        self.updateAlarmState()
    }

    func showFinishedMessage() {
        if self.prefs.showCountDown {
            self.button.buttonTitle = "Happening now!"
        } else {
            self.button.buttonTitle = ""
        }
    }
}

extension MenuBarController {
    func startFlashingTimer() {
        if self.prefs.blink {
            self.logger.log("starting flashing timer")

            self.showFinishedMessage()
            self.flashingTimer.start(withInterval: 0.5,
                                     fireCount: SimpleTimer.RepeatEndlessly) { [weak self] _ in
                guard let self = self else { return }

                if self.alarmState == .firing1 {
                    self.alarmState = .firing2
                } else {
                    self.alarmState = .firing1
                }

                self.button.contentTintColor = self.colorForState(self.alarmState)
            }
        } else {
            self.flashingTimer.stop()
            self.updateAlarmState()
        }
    }
}

extension MenuBarController: CountDownDelegate {
    func startCountdown() {
        if self.prefs.showCountDown,
           let nextFireDate = CoreControllers.shared.scheduleController.schedule.nextAlarmDate {
            self.countDown.start(withFireDate: nextFireDate)
        } else {
            self.stopCountdown()
        }
    }

    func stopCountdown() {
        self.countDown.stop()
        self.button.buttonTitle = ""
    }

    public func countdown(_ countDown: CountDownTimer, didUpdate displayString: String) {
        self.button.buttonTitle = displayString
    }

    public func countdownDisplayFormatter(_ countDown: CountDownTimer) -> TimeDisplayFormatter {
        switch self.prefs.countDownFormat {
        case .short:
            return TerseTimeDisplayFormatter(showSecondsWithMinutes: 2.0)

        case .long:
            return VerboseTimeDisplayFormatter(showSecondsWithMinutes: 2.0)

        case .digitalClock:
            return DigitalClockTimeDisplayFormatter(showSecondsWithMinutes: 2.0)
        }
    }

    public func countdown(_ countDown: CountDownTimer, didFinish displayString: String) {
        self.button.buttonTitle = displayString
    }

    public func countdown(_ countDown: CountDownTimer, willStart: Bool) {
        self.button.buttonTitle = ""
    }
}

extension MenuBarController {
    enum AlarmState: String {
        case none
        case normal
        case warning
        case firing1
        case firing2
    }

    func colorForState(_ state: AlarmState) -> NSColor {
        switch state {
        case .none:
            return NSColor.white

        case .normal:
            return NSColor.white

        case .warning:
            return NSColor.systemYellow

        case .firing1:
            return NSColor.systemRed

        case .firing2:
            return NSColor.systemYellow
        }
    }

    func updateAlarmState() {
        guard self.prefs.showInMenuBar else {
            self.stopCountdown()
            self.flashingTimer.stop()
            self.alarmState = .none
            return
        }

        if self.isAlarmFiring {
            self.alarmState = .firing1
        } else if let nextDate = CoreControllers.shared.scheduleController.schedule.nextAlarmDate,
                  nextDate.isEqualToOrBeforeDate(Date().addMinutes(2)) {
            self.alarmState = .warning
        } else {
            self.alarmState = .normal
        }

        self.logger.log("updating to \(self.alarmState.rawValue)")

        switch self.alarmState {
        case .normal, .warning, .none:
            self.flashingTimer.stop()
            self.startCountdown()

        case .firing1, .firing2:
            self.stopCountdown()
            self.startFlashingTimer()
        }

        self.button.contentTintColor = self.colorForState(self.alarmState)
    }
}
