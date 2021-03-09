//
//  ListViewSection.swift
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

public protocol ListViewSectionItem: ListViewModelItem {
    var section: ListViewModel.Section? { get }
}

extension ListViewModel {
    public struct SectionLayout {
        public let rowSpacing: CGFloat
        public let insets: SDKEdgeInsets

        public static let zero = SectionLayout(rowSpacing: 0, insets: SDKEdgeInsets.zero)
    }

    open class Section: ListViewModelItem {
        public let rows: [Row]
        public let header: Adornment?
        public let footer: Adornment?
        public let layout: SectionLayout
        public var preferredSize = CGSize.noIntrinsicMetric

        public weak var model: ListViewModel?

        public init(withRows rows: [Row],
                    layout: SectionLayout = SectionLayout.zero,
                    header: Adornment? = nil,
                    footer: Adornment? = nil) {
            self.layout = layout

            self.rows = rows
            self.header = header
            self.footer = footer

            self.header?.section = self
            self.footer?.section = self

            self.rows.forEach { $0.section = self }
        }

        public func row(forIndex index: Int) -> Row? {
            guard index >= 0 && index < self.rows.count else {
                return nil
            }

            return self.rows[index]
        }

        public var rowCount: Int {
            self.rows.count
        }

        public var size: CGSize {
            if self.rowCount == 0 {
            // FUTURE: should headers/footers be optionally visible with zero rows?
                return CGSize.zero
            }

            var size = CGSize.zero

            if let header = self.header {
                let itemSize = header.size
                size.height += itemSize.height
                size.width = max(size.width, itemSize.width)
            }

            if let footer = self.footer {
                let itemSize = footer.size
                size.height += itemSize.height
                size.width = max(size.width, itemSize.width)
            }

            for row in self.rows {
                let itemSize = row.size
                size.height += itemSize.height
                size.width = max(size.width, itemSize.width)
            }

            size.height += self.layout.rowSpacing * (CGFloat(self.rowCount) - 1)

            size.height += self.layout.insets.top + self.layout.insets.bottom
            // NOTE: width insets calculated by children

            if self.preferredSize.width != NSView.noIntrinsicMetric {
                size.width = self.preferredSize.width
            }

            if self.preferredSize.height != NSView.noIntrinsicMetric {
                size.height = self.preferredSize.height
            }

            return size
        }
    }
}
