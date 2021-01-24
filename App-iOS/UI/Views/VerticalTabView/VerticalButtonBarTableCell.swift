//
//  VerticalButtonListTableCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
import UIKit

class VerticalButtonListTableCell : UITableViewCell, TableViewRowCell {
    
    typealias DataType = VerticalTabItem
    
    static var cellHeight: CGFloat {
        return 40.0
    }
 
    func configureCell(withData data: DataType, indexPath: IndexPath, isSelected: Bool) {
        self.textLabel?.text = data.title
    }

}
