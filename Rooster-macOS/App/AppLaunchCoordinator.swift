//
//  AppLaunchCoordinator.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/30/21.
//

import AppKit
import Foundation
import RoosterCore

public class AppLaunchCoordinator: Loggable {
    public static let applicationStateVersion = 10

    public enum State: String, Equatable, CustomStringConvertible {
        case prepare
        case loadStoredData
        case loadPreferences
        case loadSchedule
        case resetIfNeeded
        case finished

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue == rhs.rawValue
        }

        public var description: String {
            self.rawValue
        }
    }

    private var resetAppState = false

    public init() {
    }

    public func begin(completion: @escaping () -> Void) {
        self.changeState(to: .prepare, completion: completion)
    }

    private func prepare(completion: @escaping () -> Void) {
        let stateVersion = AppControllers.shared.savedState.applicationStateVersion
        if  stateVersion != Self.applicationStateVersion {
            self.logger.log("""
                State version doesn't match, will reset app state. \
                Got: \(stateVersion), expected: \(Self.applicationStateVersion)")
                """)

            self.resetAppState = true
        }

        if NSEvent.modifierFlags.intersection(.deviceIndependentFlagsMask) == .option {
            self.logger.log("Option key help down, will reset app state")
            self.resetAppState = true
        }

        AlarmNotification.setAlarmStartActionsFactory()

        DispatchQueue.main.async {
            completion()
        }
    }

    private func loadPreferences(completion: @escaping () -> Void) {
        self.logger.log("loading preferences...")
        AppControllers.shared.preferences = PreferencesController()
        AppControllers.shared.preferences.readFromStorage { [weak self] success, error in
            guard let self = self else { return }

            if success {
                self.logger.log("Loaded Preferences ok")
            } else {
                self.logger.error("Failed to load preferences with error: \(String(describing: error))")
            }

            completion()
        }
    }

    private func openScheduleController(completion: @escaping () -> Void) {
        self.logger.log("Opening schedule...")

        let scheduleController = CoreControllers.shared.scheduleController
        let prefsController = AppControllers.shared.preferences!

        scheduleController.open(withScheduleBehaviorProvider: prefsController) { [weak self] success, error in
            guard let self = self else { return }

            if success {
                self.logger.log("Opened schedule ok")
            } else {
                self.logger.error("Failed to open schedule with error: \(String(describing: error))")

//                    errorQueue.append({
//
//                        var savedState = SavedState()
//                        savedState.setBool(false, forKey: .lookedForCalendarOnFirstRun)
//
//                        self?.showDataModelErrorAlert(error)
//                    })
            }

            completion()
        }
    }

    private func resetIfNeeded(completion: @escaping () -> Void) {
        if self.resetAppState {
            self.logger.log("Resetting application State...")
            self.resetAppLaunchState {
                self.logger.log("Resetting application State ok")

                completion()
            }
        } else {
            self.logger.log("Not resetting application State")
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    public func beginLoadingStoredData(completion: @escaping () -> Void) {
        self.logger.log("authenticating and loading sound folder...")

        var errorQueue:[() -> Void] = []

        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()

        self.logger.log("requesting access to user notifications...")

        CoreControllers.shared.userNotificationController.requestAccess { [weak self] success, error in
            guard let self = self else { return }

            if success {
                self.logger.log("granted access to user notifications ok")
            } else {
                self.logger.error("Error requesting user notification access: \(String(describing: error))")
            }

            dispatchGroup.leave()
        }

        self.logger.log("loading sound folder...")
        SoundFolder.startLoadingDefaultSoundFolder { [weak self] success, _, error in
            guard let self = self else { return }

            if success {
                self.logger.log("Loaded sound folder ok")
            } else {
                self.logger.error("Failed to load sound folder with error: \(String(describing: error))")
            }

            dispatchGroup.leave()
        }

        self.logger.log("requesting access to calendars...")

        CoreControllers.shared.scheduleController.requestAccessToCalendars { [weak self] success, error in
            guard let self = self else { return }

            if success {
                self.logger.log("authenticated calendar access ok")
            } else {
                self.logger.error("Failed to authenticate calendar access with error: \(String(describing: error))")

                if !success {
                    errorQueue.append {
                        AppControllers.shared.errorController.showUnableToAuthenticateError(error)
                    }
                }
            }

            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.logger.log("authenticated and loaded sound folder ok data ok")
            errorQueue.forEach { $0() }
            completion()
        }
    }

    func resetAppLaunchState(completion: @escaping () -> Void) {
        self.logger.log("resetting app state...")

        let dictionaryRepresentation = UserDefaults.standard.dictionaryRepresentation()
        for key in dictionaryRepresentation.keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()

        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        dispatchGroup.enter()

        AppControllers.shared.preferences.delete { [weak self] success, error in
            guard let self = self else { return }

            if success {
                self.logger.log("deleted preferences data ok")
            } else {
                self.logger.error("deleting preferences data failed with error: \(String(describing: error))")
            }

            dispatchGroup.leave()
        }

        CoreControllers.shared.scheduleController.reset { success, error in
            if success {
                self.logger.log("reset schedule ok")
            } else {
                self.logger.error("resetting schedule failed with error: \(String(describing: error))")
            }

            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            AppControllers.shared.savedState.applicationStateVersion = Self.applicationStateVersion
            self?.logger.log("Reset application state ok")
            completion()
        }
    }

    func finish(completion: @escaping () -> Void) {
        self.logger.info("finished launching ok")
        completion()
    }

    private func changeState(to state: State, completion: @escaping () -> Void) {
        self.logger.log("changing to state to: \(state.description)")

        switch state {
        case .prepare:
            self.prepare { [weak self] in
                self?.changeState(to: .loadStoredData, completion: completion)
            }

        case .loadStoredData:
            self.beginLoadingStoredData { [weak self] in
                self?.changeState(to: .loadPreferences, completion: completion)
            }

        case .loadPreferences:
            self.loadPreferences { [weak self] in
                self?.changeState(to: .loadSchedule, completion: completion)
            }

        case .loadSchedule:
            self.openScheduleController { [weak self] in
                self?.changeState(to: .resetIfNeeded, completion: completion)
            }

        case .resetIfNeeded:
            self.resetIfNeeded { [weak self] in
                self?.changeState(to: .finished, completion: completion)
            }

        case .finished:
            self.finish(completion: completion)
        }
    }
}
