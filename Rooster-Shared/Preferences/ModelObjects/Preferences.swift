//
//  Preferences.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import RoosterCore

public struct Preferences : CustomStringConvertible, Loggable, Codable {

    static let version = 3
    
    public var soundPreferences: SoundPreferences  {
        didSet { self.updateTimestamp() }
    }
    
    public var notificationPreferences: NotificationPreferences {
        didSet { self.updateTimestamp() }
    }
    
    public var menuBarPreferences: MenuBarPreferences {
        didSet { self.updateTimestamp() }
    }
    
    public var generalPreferences: GeneralPreferences {
        didSet { self.updateTimestamp() }
    }
    
    private var timestamp: Date
    
    private mutating func updateTimestamp() {
        self.timestamp = Date()
    }

    public init(withSoundPreferences soundPreferences: SoundPreferences,
                notificationPreferences: NotificationPreferences,
                menuBarPreferences: MenuBarPreferences,
                generalPreferences: GeneralPreferences) {
        
        self.timestamp = Date()
        self.soundPreferences = soundPreferences
        self.notificationPreferences = notificationPreferences
        self.menuBarPreferences = menuBarPreferences
        self.generalPreferences = generalPreferences
    }
    
    private init() {
        self.init(withSoundPreferences: SoundPreferences.default,
                  notificationPreferences: NotificationPreferences.default,
                  menuBarPreferences: MenuBarPreferences.default,
                  generalPreferences: GeneralPreferences.default)
    }
    
    public var description: String {
        return """
        \(type(of:self)): \
        timestamp: \(self.timestamp.shortDateAndLongTimeString) \
        generaro: \(self.generalPreferences.description), \
        notifications: \(self.notificationPreferences.description), \
        sounds: \(self.soundPreferences.description), \
        menuBar: \(self.menuBarPreferences.description)
        """
    }
}

extension Preferences {
    public static let `default` = Preferences()
}
