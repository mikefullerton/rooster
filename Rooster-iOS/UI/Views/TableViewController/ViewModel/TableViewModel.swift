//
//  TableViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

protocol TableViewModelProtocol {
    var sections: [TableViewSectionProtocol] { get }
}

extension TableViewModelProtocol {
    var sectionCount: Int {
        self.sections.count
    }

    func section(forIndex index: Int) -> TableViewSectionProtocol? {
        guard index >= 0, index < self.sections.count else {
            return nil
        }

        return self.sections[index]
    }

    func header(forSection section: Int) -> TableViewSectionAdornmentProtocol? {
        self.section(forIndex: section)?.header
    }

    func footer(forSection section: Int) -> TableViewSectionAdornmentProtocol? {
        self.section(forIndex: section)?.footer
    }

    func row(forSection section: Int, row: Int) -> TableViewRowProtocol? {
        if let section = self.section(forIndex: section) {
            return section.row(forIndex: row)
        }

        return nil
    }

    func row(forIndexPath indexPath: IndexPath) -> TableViewRowProtocol? {
        if let section = self.section(forIndex: indexPath.section) {
            return section.row(forIndex: indexPath.item)
        }
        return nil
    }

    var height: CGFloat {
        var height: CGFloat = 0

        for section in sections {
            height += section.preferredHeight
        }

        return height
    }
}

struct TableViewModel<ContentType, ViewType>: TableViewModelProtocol
            where ViewType: UITableViewCell, ViewType: TableViewRowCell {
    let sections: [TableViewSectionProtocol]

    init(withData data: [ContentType]) {
        let section = TableViewSection<ContentType, ViewType>(withRowData: data)
        self.sections = [ section ]
    }
}
