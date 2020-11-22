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
        
    func updatedViewModel() -> TableViewModelProtocol {
        return TableViewModel()
    }
    
    @objc func handleModelReloadEvent(_ notif: Notification) {
        self.viewModel = self.updatedViewModel()
        self.tableView.reloadData()
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

//        guard let height = header.height else {
//            return UITableView.automaticDimension
//        }
        
        return header.height
    }

    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let footer = self.viewModel.footer(forSection:section) else {
            return 0
        }
        
//        guard let height = footer.height else {
//            return UITableView.automaticDimension
//        }
        
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
