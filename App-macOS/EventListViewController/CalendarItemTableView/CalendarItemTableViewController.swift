//
//  CalendarItemTableViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
import Cocoa

class CalendarItemTableViewController<ViewModel> : TableViewController<ViewModel>, DataModelAware where ViewModel: TableViewModelProtocol {
    
    private var reloader: DataModelReloader? = nil

    override func viewWillAppear() {
        super.viewWillAppear()
        self.reloader = DataModelReloader(for: self)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.reloader = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer?.backgroundColor = Theme(for: self.view).windowBackgroundColor.cgColor
//        self.tableView.allowsSelection = false
//        self.tableView.separatorStyle = .none
//        self.tableView.contentInsetAdjustmentBehavior = .never
    }
    
    func dataModelDidReload(_ dataModel: DataModel) {
        self.reloadData()
    }

    override var preferredContentSize: CGSize {
        get {
            if let viewModel = self.viewModel {
                return CGSize(width: self.view.frame.size.width, height: viewModel.height)
            }
            return super.preferredContentSize
        }
        set(size) {
            
        }
    }
}
