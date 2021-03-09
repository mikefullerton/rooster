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

public protocol ListViewModelItem {
    var size: CGSize { get }
    var model: ListViewModel? { get }
}

open class ListViewModel {
    public let sections: [Section]
    public var preferredSize = CGSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    public var verticalSectionSpacing: CGFloat = 0

    public init(withSections sections: [Section]) {
        self.sections = sections
        self.sections.forEach { $0.model = self }
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

    public init(withContent content: [Any], rowControllerType: AbstractListViewRowController.Type) {
        let rows: [Row] = content.map {
            Row(withContent: $0, rowControllerClass: rowControllerType)
        }

        self.sections = [ Section(withRows: rows) ]
    }
}

extension ListViewModel {
    // MARK: - Content Access

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

extension ListViewModel {
    // MARK: Size utils

    public var size: CGSize {
        var calculatedSize = CGSize.zero

        for section in self.sections {
            let sectionSize = section.size
            calculatedSize.height += sectionSize.height
            calculatedSize.width = max(calculatedSize.width, sectionSize.width)
        }

        calculatedSize.height += (CGFloat(self.sections.count - 1) * self.verticalSectionSpacing)

        if self.preferredSize.width != NSView.noIntrinsicMetric {
            calculatedSize.width = self.preferredSize.width
        }

        if self.preferredSize.height != NSView.noIntrinsicMetric {
            calculatedSize.height = self.preferredSize.height
        }

        return calculatedSize
    }

    public func size(forItem item: ListViewModelItem) -> CGSize {
        var size = item.size
        if self.preferredSize.width != NSView.noIntrinsicMetric {
            size.width = self.preferredSize.width
        }
        return size
    }

    public func size(forItem item: ListViewSectionItem) -> CGSize {
        assert(item.model != nil, "model is nil")
        assert(item.section != nil, "section is nil")
        assert(item.section === self, "wrong section")

        guard let section = item.section else {
            return CGSize.zero
        }

        var size = item.size

        size.width += section.layout.insets.left + section.layout.insets.right

        // Hmmmm, Should preferred size override insets?

        if self.preferredSize.width != NSView.noIntrinsicMetric {
            size.width = self.preferredSize.width
        }

        if self.preferredSize.width != NSView.noIntrinsicMetric {
            size.width = self.preferredSize.width
        }

        return size
    }
}
