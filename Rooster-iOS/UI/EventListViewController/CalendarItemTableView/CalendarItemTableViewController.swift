//
//  CalendarItemTableViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
import UIKit

class CalendarItemTableViewController<ViewModel>: ListViewController<ViewModel> where ViewModel: TableViewModelProtocol {
    private var scheduleUpdateHandler = ScheduleEventListener()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scheduleUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else { return }
            self.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.scheduleUpdateHandler = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Theme(for: self).windowBackgroundColor
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
        self.tableView.contentInsetAdjustmentBehavior = .never
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
