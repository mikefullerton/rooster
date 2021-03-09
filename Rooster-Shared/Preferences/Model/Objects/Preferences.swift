//
//  Preferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import RoosterCore

public struct Preferences : CustomStringConvertible, Loggable, Codable, Equatable {
    static let version = 3
    
    public var soundPreferences: SoundPreferences
    
    public var notifications: NotificationPreferences
    
    public var menuBar: MenuBarPreferences
    
    public var general: GeneralPreferences
    
    public var dataModelPreferences: EKDataModelSettings
    
    public var calendar: CalendarPreferences
    
    public var reminders: ReminderPreferences
    
    public var events: EventPreferences
    
    public let version: Int
    
    public init(withSoundPreferences soundPreferences: SoundPreferences,
                notifications: NotificationPreferences,
                menuBarPreferences: MenuBarPreferences,
                general: GeneralPreferences,
                dataModelPreferences: EKDataModelSettings,
                calendar: CalendarPreferences,
                events: EventPreferences,
                reminders: ReminderPreferences) {
        
        self.version = Self.version
        self.soundPreferences = soundPreferences
        self.notifications = notifications
        self.menuBar = menuBarPreferences
        self.general = general
        self.dataModelPreferences = dataModelPreferences
        self.calendar = calendar
        self.events = events
        self.reminders = reminders
    }
    
    private init() {
        self.init(withSoundPreferences: SoundPreferences.default,
                  notifications: NotificationPreferences.default,
                  menuBarPreferences: MenuBarPreferences.default,
                  general: GeneralPreferences.default,
                  dataModelPreferences: EKDataModelSettings.default,
                  calendar: CalendarPreferences.default,
                  events: EventPreferences.default,
                  reminders: ReminderPreferences.default)
    }
    
    public var description: String {
        return """
        \(type(of:self)): \
        general: \(self.general.description), \
        notifications: \(self.notifications.description), \
        sounds: \(self.soundPreferences.description), \
        menuBar: \(self.menuBar.description), \
        dataMode: \(self.dataModelPreferences.description) \
        calendar: \(self.calendar.description) \
        events: \(self.events.description) \
        reminders: \(self.reminders.description)
        """
    }
    
}

extension Preferences {
    public static let `default` = Preferences()
}
