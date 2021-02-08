//
//  DirectoryReader.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

struct DirectoryReader {
    func readContentsFromDisk() throws {

        if let url = self.url {
            var files:[DirectoryItemProtocol] = []
            var directories:[DirectoryProtocol] = []
            var contents:[DirectoryItemProtocol] = []

            let contentPaths = try FileManager.default.contentsOfDirectory(atPath: url.path)
            for itemPath in contentPaths {
                if itemPath.hasPrefix(".") {
                    continue
                }

                let itemURL = url.appendingPathComponent(itemPath)

                var isDir : ObjCBool = false
                if FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                    if isDir.boolValue {

                        var dir: DirectoryProtocol? = nil
                        if let factory = self.factory {
                            dir = try factory.directory(self, createDirectoryWithURL: itemURL, parent: self)
                        } else {
                            let directory = Directory(withID: url.absoluteString,
                                            url: url,
                                            parent: parent)
                            try directory.readContentsFromDisk()
                            
                            dir = directory
                        }
                        
                        if dir != nil {
                            contents.append(dir!)
                            directories.append(dir!)
                        }
                    } else {
                        var file: DirectoryItemProtocol? = nil
                        if let factory = self.factory {
                            file = factory.directory(self, createFileWithURL: itemURL, parent: self)
                        } else {
                            file = DirectoryItem(withID: url.absoluteString,
                                                  url: url,
                                                  parent: parent)
                        }
                            
                        if file != nil {
                            contents.append(file!)
                            files.append(file!)
                        }
                    }
                }
            }

            self.contents = contents.sorted(by: { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
            })

            self.files = files.sorted { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
            }

            self.directories = directories.sorted { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
            }
        }
    }
}
