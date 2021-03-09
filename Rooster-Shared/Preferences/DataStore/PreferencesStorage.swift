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
    
    public let directoryURL: URL
    public let soundsSetsFolderURL: URL
    
    private let prefsFile: JsonFile<Preferences>
    
    private var createdFolders: Bool = false
    
    init() {
    
        let applicationSupportDirectory = FileManager.default.applicationSupportDirectoryURL
        
        let directoryURL = applicationSupportDirectory.appendingPathComponent(Bundle.main.bundleIdentifier ?? "")
        let preferencesFileURL = directoryURL.appendingPathComponent("Preferences.json")
        let soundsSetsFolderURL = directoryURL.appendingPathComponent("Sound Sets")

        self.directoryURL = directoryURL
        self.soundsSetsFolderURL = soundsSetsFolderURL
        self.prefsFile = JsonFile<Preferences>(withURL: preferencesFileURL)
    }
    
    private func createFoldersIfNeeded() throws {
        if !self.createdFolders {
            try FileManager.default.createFolderIfNeeded(atURL: self.directoryURL)
            try FileManager.default.createFolderIfNeeded(atURL: self.soundsSetsFolderURL)
        }
    }
    
    func read() throws -> Preferences {
        try self.createFoldersIfNeeded()
        return try self.prefsFile.read()
    }
    
    func write(_ preferences: Preferences) throws {
        try self.createFoldersIfNeeded()
        try self.prefsFile.write(preferences)
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
