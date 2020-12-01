//
//  TableViewRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct TableViewRow : TableViewRowProtocol {
    let title: String
    let height: CGFloat
    
    init(withTitle title: String,
         height: CGFloat = 26) {
        self.title = title
        self.height = height
    }
    
    var cellReuseIdentifer: String {
        return "TableViewRow"
    }
    
    var cellClass: UITableViewCell.Type {
        return UITableViewCell.self
    }
    
    func willDisplay(cell: UITableViewCell) {
        cell.textLabel?.text = self.title
    }
}


