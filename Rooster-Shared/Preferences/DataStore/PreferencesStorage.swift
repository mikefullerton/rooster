//
//  ApplicationSupportFolderPreferencesStorage.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/8/21.
//

import Cocoa
import Foundation
import RoosterCore

public class PreferencesStorage: JsonFile<Preferences> {
    public static let directoryURL = FileManager.default.applicationSupportDirectory
    public static let soundsSetsFolderURL = FileManager.default.applicationSupportPath(for: "Sound Sets")

    private var createdFolders = false

    init() {
        super.init(withURL: FileManager.default.applicationSupportPath(for: "Preferences.json"))
    }

    private func createFoldersIfNeeded() throws {
        if !self.createdFolders {
            try FileManager.default.createFolderIfNeeded(atURL: Self.directoryURL)
            try FileManager.default.createFolderIfNeeded(atURL: Self.soundsSetsFolderURL)
        }
    }

    override public func readSynchronously() throws -> Preferences {
        try self.createFoldersIfNeeded()
        return try super.readSynchronously()
    }

    override public func writeSynchronously(_ preferences: Preferences) throws {
        try self.createFoldersIfNeeded()
        try super.writeSynchronously(preferences)
    }

//    fileprivate func readOrCreatePreferences() -> Preferences {
//        do {
//            if self.exists {
//                return try self.read()
//            }
//        } catch {
//            self.logger.error("Reading old preferences failed with error: \(String(describing: error))")
//        }
//
//        let prefs = Preferences.default
//        do {
//            try self.write(prefs)
//            self.logger.log("Wrote new preferences: \(prefs.description)")
//        } catch {
//            self.logger.error("Writing new preferences failed with error: \(String(describing: error))")
//        }
//
//        return prefs
//    }

//    func writePreferences(_ preferences: Preferences, previousPrefs: Preferences) {
//        do {
//            try self.write(preferences)
//        } catch {
//            self.logger.error("Writing preferences failed with error: \(String(describing: error))")
//        }
//
//        self.logger.log("Wrote preferences: \(preferences.description)")
//    }

}
