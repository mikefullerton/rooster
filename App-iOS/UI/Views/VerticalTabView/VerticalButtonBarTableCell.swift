//
//  VerticalButtonListTableCell.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
import UIKit

class VerticalButtonListTableCell : UITableViewCell, TableViewRowCell {
    
    typealias ContentType = VerticalTabItem
    
    static var viewHeight: CGFloat {
        return 40.0
    }
 
    func viewWillAppear(withContent content: VerticalTabItem) {
        self.textLabel?.text = content.title
    }

}
