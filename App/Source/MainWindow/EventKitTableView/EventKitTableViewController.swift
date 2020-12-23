//
//  EventKitTableViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
import UIKit

class EventKitTableViewController<ViewModel> : TableViewController<ViewModel> where ViewModel: TableViewModelProtocol {
    
    private var reloader: DataModelReloader? = nil

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloader = DataModelReloader(for: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.reloader = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
    }
}
