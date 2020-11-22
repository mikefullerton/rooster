//
//  CalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class CalendarListViewController : TableViewController {
    
    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataModelDidChange(_:)), name: DataModel.DidChangeEvent, object: nil)
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func updateViewModel() {
        self.update(viewModel: CalenderListViewModel(withCalendars: DataModel.instance.calendars,
                                                     delegateCalendars: DataModel.instance.delegateCalendars))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateViewModel()
    }

    @objc private func dataModelDidChange(_ notif: Notification) {
        self.updateViewModel()
    }
}
