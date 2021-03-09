//
//  SoundFolder+MetaDataFiles.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/1/21.
//

import Foundation
import RoosterCore

extension SoundFolder {
    convenience init(withCreatingDescriptorsInDirectory directory: DirectoryIterator,
                     withID identifier: String) throws {
        let descriptor = try SoundFolderDescriptor.writeNewSoundFolderItemsDescriptor(forDirectoryItem: directory, withID: identifier)

        self.init(withDescriptor: descriptor, atPath: directory.url)

        try self.addContentsWithCreatingDescriptors(inDirectory: directory)
    }

    convenience init(withCreatingDescriptorsInDirectory directory: DirectoryIterator) throws {
        let descriptor = try SoundFolderDescriptor.writeNewSoundFolderItemsDescriptor(forDirectoryItem: directory, withID: String.guid)
        self.init(withDescriptor: descriptor, atPath: directory.url)
        try self.addContentsWithCreatingDescriptors(inDirectory: directory)
    }

    private func addContentsWithCreatingDescriptors(inDirectory directory: DirectoryIterator) throws {
        for file in directory.files where file.isSoundFile {
            let fileDescriptor = try SoundFileDescriptor.writeNewSoundFolderItemsDescriptor(forDirectoryItem: file,
                                                                                            withID: String.guid)
            let soundFile = SoundFile(withDescriptor: fileDescriptor, atPath: file.url)
            self.addSoundFile(soundFile)
        }

        for directory in directory.directories {
            self.addSubFolder(try SoundFolder(withCreatingDescriptorsInDirectory: directory))
        }
    }
}

extension DirectoryItem {
    var isSoundFile: Bool {
        self.url.isSoundFile
    }
}

extension SoundFolderItemDescriptor {
    private static func cleanupName(_ url: URL?) -> String {
        if let theURL = url {
            var cleanedName = theURL.deletingPathExtension().lastPathComponent

            [ "-", "_" ].forEach { cleanedName = cleanedName.replacingOccurrences(of: $0, with: " ") }

            return cleanedName
        }

        return ""
    }

    public static func readOrCreateDescriptor(forDirectoryItem directoryItem: DirectoryItem,
                                              withID optionalIDOrNil: String? = nil) throws -> FileType? {
        if !directoryItem.isDirectory && !directoryItem.isSoundFile {
            return nil
        }

        let url = directoryItem.url

        let fileURL = FileType.metadataFileURL(fromURL: url)
        let jsonFile = JsonFile<FileType>(withURL: fileURL)

        if jsonFile.exists {
            var descriptor = try jsonFile.readSynchronously()

            if let optionalID = optionalIDOrNil {
                var metadata = descriptor.metadata

                if metadata.id == optionalID {
                    return descriptor
                }

                metadata.id = optionalID
                descriptor.metadata = metadata

                try jsonFile.writeSynchronously(descriptor)

                return descriptor
            }

            self.logger.log("Loaded descriptor: \(descriptor.description) from path: \(url.path)")

            return descriptor
        }

        let newID = optionalIDOrNil == nil ? String.guid : optionalIDOrNil!

        let newFile = FileType(withID: newID, displayName: Self.cleanupName(url))

        self.logger.log("Creating desc \(newFile.description) at: \(url.path)")

        try jsonFile.writeSynchronously(newFile)

        return newFile
    }

    public static func writeNewSoundFolderItemsDescriptor(forDirectoryItem directoryItem: DirectoryItem,
                                                          withID optionalIDOrNil: String? = nil) throws -> FileType {
        let url = directoryItem.url

        let fileURL = FileType.metadataFileURL(fromURL: url)
        let jsonFile = JsonFile<FileType>(withURL: fileURL)

        if jsonFile.exists {
            try jsonFile.deleteSynchronously()
        }

        let newID = optionalIDOrNil == nil ? String.guid : optionalIDOrNil!

        let newFile = FileType(withID: newID, displayName: Self.cleanupName(url))

        self.logger.log("Creating desc \(newFile.description) at: \(url.path)")

        try jsonFile.writeSynchronously(newFile)

        return newFile
    }
}
