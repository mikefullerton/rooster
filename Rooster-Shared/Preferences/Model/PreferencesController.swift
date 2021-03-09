//
//  PreferencesDataModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
import RoosterCore

public class PreferencesController: ObservableObject, Loggable {
    public static let preferencesDidChangeEvent = Notification.Name(rawValue: "PreferencesDidChangeEvent")
    public static let preferencesDidResetEvent = Notification.Name(rawValue: "PreferencesDidResetEvent")

    // in the user info in event notification
    public static let newPreferencesKey = "newPreferencesKey"
    public static let oldPreferencesKey = "oldPreferencesKey"

    fileprivate var storage = PreferencesStorage()

    fileprivate let notifier = DeferredCallback()

    private var hasBeenRead = false

    public init() {
        self.preferences = Preferences.default
    }

    public var general: GeneralPreferences {
        get { self.preferences.general }
        set {
            if self.preferences.general != newValue {
                self.logger.debug("\(#function) will update: \(self.preferences.general.description), newValue: \(newValue)")
                self.preferences.general = newValue
            }
        }
    }

    public var soundPreferences: SoundPreferences {
        get { self.preferences.soundPreferences }
        set {
            if self.preferences.soundPreferences != newValue {
                self.logger.debug("\(#function) will update: \(self.preferences.general.description), newValue: \(newValue)")
                self.preferences.soundPreferences = newValue
            }
        }
    }

    public var menuBar: MenuBarPreferences {
        get { self.preferences.menuBar }
        set {
            if self.preferences.menuBar != newValue {
                self.logger.debug("\(#function) will update: \(self.preferences.menuBar.description), newValue: \(newValue)")
                self.preferences.menuBar = newValue
            }
        }
    }

    public var notifications: NotificationPreferences {
        get { self.preferences.notifications }
        set {
            if self.preferences.notifications != newValue {
                self.logger.debug("\(#function) will update: \(self.preferences.notifications.description), newValue: \(newValue)")
                self.preferences.notifications = newValue
            }
        }
    }

    public var calendar: CalendarPreferences {
        get { self.preferences.calendar }
        set {
            if self.preferences.calendar != newValue {
                self.logger.debug("\(#function) will update: \(self.preferences.calendar.description), newValue: \(newValue)")
                self.preferences.calendar = newValue
            }
        }
    }

    public var events: EventPreferences {
        get { self.preferences.events }
        set {
            if self.preferences.events != newValue {
                self.logger.debug("\(#function) will update: \(self.preferences.events.description), newValue: \(newValue)")
                self.preferences.events = newValue
            }
        }
    }

    public var reminders: ReminderPreferences {
        get { self.preferences.reminders }
        set {
            if self.preferences.reminders != newValue {
                self.logger.debug("\(#function) will update: \(self.preferences.reminders.description), newValue: \(newValue)")
                self.preferences.reminders = newValue
            }
        }
    }

    public var preferences: Preferences {
        didSet {
            guard self.hasBeenRead else {
                self.logger.log("preferences not read yet, ignoring update")
                return
            }

            if oldValue != self.preferences {
                self.logger.debug("Preferences did update")
                self.notify(newPrefs: self.preferences, oldPrefs: oldValue)

                self.storage.write(self.preferences) { success, _, error in
                    if success {
                        self.logger.log("Wrote preferences on update ok")
                    } else {
                        // FUTURE: handle errors

                        self.logger.error("Writing preferences on update failed with error: \(String(describing: error))")
                    }
                }
            }
        }
    }

    // swiftlint:disable todo
    // TODO: support individual settings in future release
    // swiftlint:enable todo
    public func preferences(forItemIdentifier itemIdentifier: String) -> ItemPreference {
        ItemPreference(with: self.preferences.soundPreferences)
    }
}

extension Notification {
    public var oldPreferences: Preferences? {
        self.userInfo?[PreferencesController.oldPreferencesKey] as? Preferences
    }
    public var newPreferences: Preferences? {
        self.userInfo?[PreferencesController.newPreferencesKey] as? Preferences
    }
}

extension PreferencesController {
    fileprivate func removeOldPrefIfNeeded() {
        if UserDefaults.standard.object(forKey: "preferences") != nil {
            UserDefaults.standard.removeObject(forKey: "preferences")
            UserDefaults.standard.synchronize()
        }
    }

    fileprivate func notify(newPrefs: Preferences, oldPrefs previousPrefsOrNil: Preferences?) {
        self.notifier.schedule {
            self.logger.log("Preferences did update, notifying")

            var userInfo: [String: Any] = [:]

            if let previousPrefs = previousPrefsOrNil {
                userInfo = [
                    PreferencesController.oldPreferencesKey: previousPrefs,
                    PreferencesController.newPreferencesKey: newPrefs
                ]
            }

            NotificationCenter.default.post(name: PreferencesController.preferencesDidChangeEvent,
                                            object: self,
                                            userInfo: userInfo)
        }
    }
}

extension PreferencesController {
    public func readFromStorage(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.storage.readOrCreate(defaultData: self.preferences) { [weak self] success, readPreferences, error in
            guard let self = self else { return }

            if success {
                self.logger.log("loading preferences ok")

                assert(readPreferences != nil, "should not get nil prefs on successfull read" )

                self.preferences = readPreferences!
                self.removeOldPrefIfNeeded()
            } else {
                self.logger.error("loading preferences failed: \(String(describing: error))")
                self.preferences = Preferences.default
            }

            self.hasBeenRead = true

            completion(true, nil)
        }
    }

    public func delete(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.storage.delete { success, error in
            if success {
                self.logger.log("Deleted preferences")
            } else {
                self.logger.error("Deleting preferences failed with error: \(String(describing: error))")
            }
            completion(success, error)

            self.preferences = Preferences.default
        }
    }
}

extension PreferencesController: ScheduleControllerBehaviorProvider {
    public func scheduleControllerScheduleBehavior(_ controller: ScheduleController) -> ScheduleBehavior {
        self.preferences.scheduleBehavior
    }
}
