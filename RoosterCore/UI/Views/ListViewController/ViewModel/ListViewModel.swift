//
//  ListViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class ListViewModel {
    public let sections: [Section]

    public init(withSections sections: [Section]) {
        self.sections = sections
    }

    public var sectionCount: Int {
        self.sections.count
    }

    public var rowCount: Int {
        var rowCount: Int = 0

        for section in self.sections {
            rowCount += section.rowCount
        }

        return rowCount
    }

    public func section(forIndex index: Int) -> Section? {
        guard index >= 0, index < self.sections.count else {
            return nil
        }

        return self.sections[index]
    }

    public func header(forSection section: Int) -> Adornment? {
        self.section(forIndex: section)?.header
    }

    public func footer(forSection section: Int) -> Adornment? {
        self.section(forIndex: section)?.footer
    }

    public func row(forSection section: Int, row: Int) -> Row? {
        if let section = self.section(forIndex: section) {
            return section.row(forIndex: row)
        }

        return nil
    }

    public func row(forIndexPath indexPath: IndexPath) -> Row? {
        if let section = self.section(forIndex: indexPath.section) {
            return section.row(forIndex: indexPath.item)
        }
        return nil
    }

    public var height: CGFloat {
        var height: CGFloat = 0

        for section in sections {
            height += section.height
        }

        return height
    }

    public init(withContent content: [Any], rowControllerType: AbstractListViewRowController.Type) {
        let rows: [Row] = content.map {
            Row(withContent: $0, rowControllerClass: rowControllerType)
        }

        self.sections = [ Section(withRows: rows) ]
    }

    public func content(forIndexPath indexPath: IndexPath) -> Any? {
        self.row(forIndexPath: indexPath)?.content
    }

    public func content<T: Any>(forIndexPath indexPath: IndexPath, contentType: T.Type) -> T? {
        let content = self.row(forIndexPath: indexPath)?.content
        return content as? T
    }

    public func indexPath<ContentType: Identifiable>(forContent content: ContentType) -> IndexPath? {
        for (sectionIndex, section) in self.sections.enumerated() {
            for(soundIndex, row) in section.rows.enumerated() {
                if let rowContent = row.content as? ContentType,
                   rowContent.id == content.id {
                    return IndexPath(item: soundIndex, section: sectionIndex)
                }
            }
        }

        return nil
    }
}
