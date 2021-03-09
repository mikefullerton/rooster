//
//  TableViewRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

protocol TableViewRowProtocol {
    var cellReuseIdentifer: String { get }

    var height: CGFloat { get }

    var cellClass: UITableViewCell.Type { get }

    func willDisplay(cell: UITableViewCell, atIndexPath indexPath: IndexPath)
}

struct TableViewRow<ContentType, ViewType>: TableViewRowProtocol
            where ViewType: UITableViewCell, ViewType: TableViewRowCell {
    let data: ContentType

    init(withData data: ContentType) {
        self.data = data
    }

    func willDisplay(cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        if let typedCell = cell as? ViewType,
           let data = self.data as? ViewType.ContentType {
            typedCell.viewWillAppear(withData: data, indexPath: indexPath, isSelected: isSelected)
        }
    }

    var cellClass: UITableViewCell.Type {
        ViewType.self
    }

    var cellReuseIdentifer: String {
        "\(type(of: self)).\(self.cellClass)"
    }

    var height: CGFloat {
        if let rowCell = self.cellClass as? ViewType.Type {
            return rowCell.viewHeight
        }

        return 24
    }
}

