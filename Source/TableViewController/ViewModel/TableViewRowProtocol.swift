//
//  TableViewRowProtocol.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

protocol TableViewRowCell {
    static var cellHeight: CGFloat { get }
}

protocol TableViewRowProtocol  {
    var cellReuseIdentifer: String { get }

    var height: CGFloat { get }

    var cellClass: UITableViewCell.Type { get }

    func willDisplay(cell: UITableViewCell)
}

protocol TypedTableViewRowProtocol : TableViewRowProtocol {
    associatedtype ViewClass where ViewClass: UITableViewCell

    func willDisplay(cell: ViewClass)
}

extension TableViewRowProtocol {
    
    var cellReuseIdentifer: String {
        return "\(type(of: self)).\(self.cellClass)"
    }

    var height: CGFloat {
        if let rowCell = self.cellClass as? TableViewRowCell.Type {
            return rowCell.cellHeight
        }
        
        return 24
    }
}

extension TypedTableViewRowProtocol {

    var cellClass: UITableViewCell.Type {
        return ViewClass.self
    }
    
    func willDisplay(cell: UITableViewCell) {
        if let typedCell = cell as? ViewClass {
            self.willDisplay(cell: typedCell)
        }
    }
}
