//
//  TableViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit



class TableViewController : UIViewController {
    private(set) var viewModel: TableViewModelProtocol = TableViewModel()

    private var tableViewDelegate: TableViewDelegate?
    private var tableViewDataSource: TableViewDataSource?
    
    var tableView: UITableView {
        return (self.view as? UITableView)!
    }
    
    func update(viewModel: TableViewModelProtocol) {
        self.viewModel = viewModel
        self.tableView.reloadData()
    }
    
    override func loadView() {
        let tableView = UITableView()
        
        self.view = tableView
        
        let delegate = TableViewDelegate(withTableViewController: self)
        let dataSource = TableViewDataSource(withTableViewController: self)
        
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        
        self.tableViewDelegate = delegate
        self.tableViewDataSource = dataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

}
