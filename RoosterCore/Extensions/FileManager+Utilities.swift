//
//  FileManager+Utilities.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

extension FileManager: Loggable {
    public func directoryExists(atPath path: String) -> Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue == true
    }

    public func directoryExists(atURL url: URL) -> Bool {
        self.directoryExists(atPath: url.path)
    }

    public func createFolderIfNeeded(atURL url: URL) throws {
        if !FileManager.default.directoryExists(atURL: url) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }

    public var applicationSupportDirectory: URL {
        guard let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory,
                                                                         in: .userDomainMask).first else {
            self.logger.error("failed to load application support folder")
            return URL.empty
        }

        return applicationSupportDirectory.appendingPathComponent(Bundle.main.bundleIdentifier ?? "")
    }

    public func applicationSupportPath(for pathComponent: String) -> URL {
        self.applicationSupportDirectory.appendingPathComponent(pathComponent)
    }
}
