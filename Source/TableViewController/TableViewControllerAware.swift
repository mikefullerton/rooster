//
//  TableViewControllerAware.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class TableViewControllerAware: NSObject {
    weak var tableViewController: TableViewController?
    
    init(withTableViewController tableViewController: TableViewController) {
        self.tableViewController = tableViewController
    }
    
    var viewModel: TableViewModelProtocol {
        return self.tableViewController!.viewModel
    }
    
    var tableView: UITableView {
        return (self.tableViewController!.view! as? UITableView)!
    }
}
