//
//  ApplicationSupportPreferencesFolder.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Foundation
import Cocoa

class ApplicationSupportPreferencesFolder: PreferencesStorage {
    
    enum Errors: Error {
        case failedToLoadApplicationSupportDirectory
        case missingPrefsFileURL
    }
    
    private var cachedPreferences: [AnyHashable: Any]?
    
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
    
    func read() throws -> [AnyHashable: Any]? {
        
        if let cached = self.cachedPreferences {
            return cached
        }
        
        try self.configureIfNeeded()
        
        if let prefsURL = self.preferencesFileURL {
            var outPreferences:[AnyHashable: Any] = [:]
            
            if let dictionary = try [AnyHashable: Any].readJSON(fromURL: prefsURL) {
                outPreferences = dictionary
            }
            
            self.cachedPreferences = outPreferences
            
            return outPreferences
        }
        
        throw Errors.missingPrefsFileURL
    }
    
    func write(_ preferences: [AnyHashable: Any]) throws {
        try self.configureIfNeeded()

        if let prefsURL = self.preferencesFileURL {
            try preferences.writeJSON(toURL: prefsURL)
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
    
    func write(_ object: DictionaryCodable) throws {
        try self.write(object.dictionaryRepresentation)
    }

}
