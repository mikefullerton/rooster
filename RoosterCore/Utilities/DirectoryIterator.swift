//
//  DirectoryTemplate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/7/21.
//

import Foundation

public protocol DirectoryItem: AnyObject {
    var isDirectory: Bool { get }
    var isFile: Bool { get }
    var url: URL { get }
    var name: String { get }
    var parent: DirectoryIterator? { get }
}

public class DirectoryIterator: DirectoryItem, Equatable, CustomStringConvertible {
    public private(set) var directories: [DirectoryIterator]
    public private(set) var files: [File]
    public private(set) var contents: [DirectoryItem]

    public let url: URL
    public private(set) weak var parent: DirectoryIterator?

    public init(withURL url: URL,
                parent: DirectoryIterator? = nil) {
        self.parent = parent
        self.url = url

        self.directories = []
        self.files = []
        self.contents = []
  }

    public init() {
        self.parent = nil
        self.url = URL.empty
        self.directories = []
        self.files = []
        self.contents = []
    }

    public var isDirectory: Bool {
        true
    }

    public var isFile: Bool {
        false
    }

    public func scan() throws {
        self.contents = []
        self.files = []
        self.directories = []

        let parentURL = self.url
        if parentURL != URL.empty {
            var files: [File] = []
            var directories: [DirectoryIterator] = []
            var contents: [DirectoryItem] = []

            let contentPaths = try FileManager.default.contentsOfDirectory(atPath: parentURL.path)
            for itemPath in contentPaths {
                if itemPath.hasPrefix(".") {
                    continue
                }

                let itemURL = parentURL.appendingPathComponent(itemPath)

                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDir) {
                    if isDir.boolValue {
                        let item = DirectoryIterator(withURL: itemURL,
                                                     parent: self)

                        try item.scan()

                        contents.append(item)
                        directories.append(item)
                    } else {
                        let item = File(withURL: itemURL, parent: self)
                        contents.append(item)
                        files.append(item)
                    }
                }
            }

            self.contents = contents.sorted { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
            }

            self.files = files.sorted { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
            }

            self.directories = directories.sorted { lhs, rhs in
                lhs.name.localizedCaseInsensitiveCompare(rhs.name) == ComparisonResult.orderedAscending
            }
        }
    }

    public typealias Visitor = (_ item: DirectoryItem, _ depth: Int) -> Void

    private func visitEach(depth: Int,
                           visitor: Visitor) {
        self.contents.forEach { item in
            visitor(item, depth)
            if let dir = item as? DirectoryIterator {
                dir.visitEach(depth: depth + 1, visitor: visitor)
            }
        }
    }

    public func visitEach(_ visitor: Visitor) {
        visitor(self, 0)
        self.visitEach(depth: 1, visitor: visitor)
    }

    public var description: String {
        var allItems: [String] = []

        self.visitEach { item, depth in
            allItems.append(item.name.prepend(with: " ", count: depth * 4))
        }

        let allItemsString = allItems.joined(separator: "\n")

        return "\(type(of: self)): \(self.url.absoluteString):\n\(allItemsString)"
    }

    public static func == (lhs: DirectoryIterator, rhs: DirectoryIterator) -> Bool {
        lhs.url == rhs.url &&
                lhs.directories == rhs.directories &&
                lhs.files == rhs.files
    }
}

extension DirectoryIterator {
    public class File: DirectoryItem, Equatable, CustomStringConvertible {
        public let url: URL
        public private(set) weak var parent: DirectoryIterator?

        public init(withURL url: URL,
                    parent: DirectoryIterator?) {
            self.url = url
            self.parent = parent
        }

        public static func == (lhs: File, rhs: File) -> Bool {
            lhs.url == rhs.url
        }

        public var description: String {
            "\(type(of: self)): url:\(self.url.absoluteString)"
        }

        public var isDirectory: Bool {
            false
        }

        public var isFile: Bool {
            true
        }
    }
}

extension DirectoryItem {
    public var name: String {
        self.url.lastPathComponent
    }

    public var relativePath: String {
        var names: [String] = []

        names.append(self.name)

        var walker = self.parent

        while walker != nil {
            names.append(walker!.name)
            walker = walker!.parent
        }

        return names.reversed().joined(separator: "/")
    }

    public func delete() throws {
        try FileManager.default.removeItem(at: self.url)
    }

    public var exists: Bool {
        FileManager.default.fileExists(atPath: self.url.path)
    }
}
