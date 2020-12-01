//
//  TableViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class TableViewController : UITableViewController {
    private(set) var viewModel: TableViewModelProtocol = TableViewModel()
    private var reloader: TableViewReloader? {
        didSet {
            if reloader != nil {
                reloader!.tableViewController = self // weak reference
            }
        }
    }
    
    func updatedViewModel() -> TableViewModelProtocol {
        return TableViewModel()
    }
    
    func updateViewModel() {
        self.viewModel = self.updatedViewModel()
        self.tableView.reloadData()
    }
    
    func createViewReloader() -> TableViewReloader? {
        return nil
    }
    
    @objc func handleModelReloadEvent(_ notif: Notification) {
        self.updateViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloader = self.createViewReloader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel = self.updatedViewModel()
        super.viewWillAppear(animated)
    }
    
    // MARK: Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = self.viewModel.row(forIndexPath: indexPath) else {
            return 0
        }
        
        return row.height
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let header = self.viewModel.header(forSection:section) else {
            return 0
        }
        return header.height
    }

    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let footer = self.viewModel.footer(forSection:section) else {
            return 0
        }
        return footer.height
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = self.viewModel.header(forSection:section) else {
            return nil
        }

        return header.view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = self.viewModel.footer(forSection:section) else {
            return nil
        }

        return footer.view
    }

    // MARK: Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let row = self.viewModel.row(forIndexPath: indexPath) else {
            return UITableViewCell()
        }

        self.tableView.register(row.cellClass, forCellReuseIdentifier: row.cellReuseIdentifer)
    
        if let cell = tableView.dequeueReusableCell(withIdentifier: row.cellReuseIdentifer)  {
            row.willDisplay(cell: cell)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = self.viewModel[section] else {
            return 0
        }
        
        return tableSection.rowCount
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionCount
    }
   
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let header = self.viewModel.header(forSection:section) else {
            return nil
        }

        return header.title
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let footer = self.viewModel.footer(forSection:section) else {
            return nil
        }

        return footer.title
    }
}

class TableViewReloader : EventNotifier {
    
    weak var tableViewController: TableViewController?
    
    init(withName name: Notification.Name,
         object: AnyObject?,
         tableViewController: TableViewController? = nil) {
        
        self.tableViewController = tableViewController
        super.init(withName: name,
                   object: object)
    }
    
    convenience init(withName name: Notification.Name,
                     tableViewController: TableViewController? = nil) {
        self.init(withName: name, object: nil, tableViewController: tableViewController)
    }
    
    @objc override func notificationReceived(_ notif: Notification) {
        if self.tableViewController != nil {
            self.tableViewController!.updateViewModel()
        }
    }
}

protocol Reloadable : AnyObject {
    func reload()
}

class Reloader : EventNotifier {
    
    weak var reloadable: Reloadable?
    
    init(withName name: Notification.Name,
         object: AnyObject?,
         reloadable: Reloadable? = nil) {
        
        self.reloadable = reloadable
        super.init(withName: name,
                   object: object)
    }
    
    convenience init(withName name: Notification.Name,
                     reloadable: Reloadable? = nil) {
        self.init(withName: name, object: nil, reloadable: reloadable)
    }
    
    @objc override func notificationReceived(_ notif: Notification) {
        if self.reloadable != nil {
            self.reloadable!.reload()
        }
    }
}

