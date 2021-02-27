//
//  ApplicationSupportFolderPreferencesStorage.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Foundation
import RoosterCore
import Cocoa

class ApplicationSupportFolderPreferencesStorage: PreferencesStorage {
    
    enum Errors: Error {
        case failedToLoadApplicationSupportDirectory
        case missingPrefsFileURL
    }
    
    private var cachedPreferences: Preferences?
    
    private var directoryURL: URL?
    private var preferencesFileURL: URL?
    private var soundsSetsFolderURL: URL?

    init() {
        self.cachedPreferences = nil
    }
    
    private func configureIfNeeded() throws {
        if (self.directoryURL != nil) {
            return
        }
        
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
        self.preferencesFileURL = preferencesFileURL
        self.soundsSetsFolderURL = soundsSetsFolderURL
    }
    
    func read() throws -> Preferences? {
        
        if let cached = self.cachedPreferences {
            return cached
        }
        
        try self.configureIfNeeded()
        
        if let prefsURL = self.preferencesFileURL {
            
            let data = try Data(contentsOf: prefsURL)
            
            let decoder = JSONDecoder()
            let prefs = try decoder.decode(Preferences.self, from: data)
            self.cachedPreferences = prefs
            return prefs
        }
        
        throw Errors.missingPrefsFileURL
    }
    
    func write(_ preferences: Preferences) throws {
        try self.configureIfNeeded()

        if let prefsURL = self.preferencesFileURL {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [ .prettyPrinted, .sortedKeys ]

            let data = try encoder.encode(preferences)

            try data.write(to: prefsURL)

            self.cachedPreferences = preferences
            return
        }

        throw Errors.missingPrefsFileURL
    }

    func delete() throws {
        try self.configureIfNeeded()

        if let prefsURL = self.preferencesFileURL {
            try FileManager.default.removeItem(at: prefsURL)
            return
        }
        
        throw Errors.missingPrefsFileURL
    }
    
    

}
