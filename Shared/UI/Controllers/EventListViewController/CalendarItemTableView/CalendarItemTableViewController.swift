//
//  CalendarItemTableViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

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
        
        self.view.sdkBackgroundColor = Theme(for: self.view).windowBackgroundColor
    
        self.view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    func dataModelDidReload(_ dataModel: DataModel) {
        self.reloadData()
    }

    override var preferredContentSize: NSSize {
        get {
            return self.viewModelContentSize
        }
        set(size) {
            
        }
    }
}
