//
//  ApplicationSupportFolderPreferencesStorage.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Foundation
import RoosterCore
import Cocoa

public class PreferencesStorage: Loggable {
    
    public enum Errors: Error {
        case failedToLoadApplicationSupportDirectory
    }
    
    private var cachedPreferences: Preferences?
    
    public let directoryURL: URL
    public let soundsSetsFolderURL: URL
    
    private let prefsFile: JsonFile<Preferences>
    
    init() throws {
        self.cachedPreferences = nil
    
        guard let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
           let bundleIdentifier = Bundle.main.bundleIdentifier else {
            
            throw Errors.failedToLoadApplicationSupportDirectory
        }
        
        let directoryURL = applicationSupportDirectory.appendingPathComponent(bundleIdentifier)
        let preferencesFileURL = directoryURL.appendingPathComponent("Preferences.json")
        let soundsSetsFolderURL = directoryURL.appendingPathComponent("Sound Sets")

        try FileManager.default.createFolderIfNeeded(atURL: directoryURL)
        try FileManager.default.createFolderIfNeeded(atURL: soundsSetsFolderURL)

        self.directoryURL = directoryURL
        self.soundsSetsFolderURL = soundsSetsFolderURL
        self.prefsFile = JsonFile<Preferences>(withURL: preferencesFileURL)
    }
    
    func read() throws -> Preferences {
        
        if let cached = self.cachedPreferences {
            return cached
        }
        
        let prefs = try self.prefsFile.read()
        self.cachedPreferences = prefs
        return prefs
    }
    
    func write(_ preferences: Preferences) throws {
        try self.prefsFile.write(preferences)
        self.cachedPreferences = preferences
    }

    func delete() throws {
        if self.prefsFile.exists {
            try self.prefsFile.delete()
            self.logger.log("deleted pref file: \(self.prefsFile.url.path)")
        }
    
    }
    
    public var exists: Bool {
        return self.prefsFile.exists
    }

}
