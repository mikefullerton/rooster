//
//  TableViewSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

protocol TableViewSectionProtocol {
    var rows: [TableViewRowProtocol] { get }

    var header: TableViewSectionAdornmentProtocol? { get }

    var footer: TableViewSectionAdornmentProtocol? { get }

    var preferredHeight: CGFloat { get }
}

extension TableViewSectionProtocol {
    func row(forIndex index: Int) -> TableViewRowProtocol? {
        guard index >= 0 && index < self.rows.count else {
            return nil
        }

        return self.rows[index]
    }

    var rowCount: Int {
        self.rows.count
    }

    var header: TableViewSectionAdornmentProtocol? {
        nil
    }

    var footer: TableViewSectionAdornmentProtocol? {
        nil
    }

    var preferredHeight: CGFloat {
        var height: CGFloat = 0

        if let header = self.header {
            height += header.preferredHeight
        }

        if let footer = self.footer {
            height += footer.preferredHeight
        }

        for row in self.rows {
            height += row.height
        }

        return height
    }
}

struct TableViewSection<ContentType, ViewType>: TableViewSectionProtocol
            where ViewType: UITableViewCell, ViewType: TableViewRowCell {
    let rows: [TableViewRowProtocol]

    let header: TableViewSectionAdornmentProtocol?

    let footer: TableViewSectionAdornmentProtocol?

    init(withRowData rows: [ContentType],
         header: TableViewSectionAdornmentProtocol? = nil,
         footer: TableViewSectionAdornmentProtocol? = nil) {
        self.rows = rows.map { TableViewRow<ContentType, ViewType>(withData: $0) }
        self.header = header
        self.footer = footer
    }

    var rowCount: Int {
        self.rows.count
    }

    func row(forIndex index: Int) -> TableViewRowProtocol? {
        guard index >= 0 && index < self.rows.count else {
            return nil
        }

        return self.rows[index]
    }
}
