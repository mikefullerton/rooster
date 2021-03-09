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

extension ListViewModel {
    public struct SectionLayout {
        public let rowSpacing: CGFloat
        public let insets: SDKEdgeInsets

        public static let zero = SectionLayout(rowSpacing: 0, insets: SDKEdgeInsets.zero)
    }

    open class Section {
        public let rows: [Row]
        public let header: Adornment?
        public let footer: Adornment?
        public let layout: SectionLayout

        public init(withRows rows: [Row],
                    layout: SectionLayout = SectionLayout.zero,
                    header: Adornment? = nil,
                    footer: Adornment? = nil) {
            self.layout = layout

            self.rows = rows
            self.header = header
            self.footer = footer
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

        public var height: CGFloat {
            if self.rowCount == 0 {
                return 0.0
            }

            var height: CGFloat = 0

            if let header = self.header {
                height += header.preferredSize.height
            }

            if let footer = self.footer {
                height += footer.preferredSize.height
            }

            for row in self.rows {
                height += row.preferredSize.height
            }

            height += self.layout.rowSpacing * (CGFloat(self.rowCount) - 1)

            return height
        }
    }
}
