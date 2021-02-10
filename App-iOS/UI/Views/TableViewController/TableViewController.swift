//
//  TableViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class TableViewController<ViewModel> : UITableViewController, Reloadable where ViewModel: TableViewModelProtocol {
    
    private(set) var viewModel: ViewModel?
    
    func provideDataModel() -> ViewModel? {
        return nil
    }
    
    // MARK: TableView
    
    public func reloadData() {
        self.viewModel = self.provideDataModel()
        self.tableView.reloadData()
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel = self.provideDataModel()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel = nil
        self.tableView.reloadData()
    }
    
    // MARK: Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let viewModel = self.viewModel,
              let row = viewModel.row(forIndexPath: indexPath) else {
            return 0
        }
        
        return row.height
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let viewModel = self.viewModel,
              let header = viewModel.header(forSection:section) else {
            return 0
        }
        return header.preferredHeight
    }

    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let viewModel = self.viewModel,
              let footer = viewModel.footer(forSection:section) else {
            return 0
        }
        return footer.preferredHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let viewModel = self.viewModel,
              let header = viewModel.header(forSection:section) else {
            return nil
        }

        return header.view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let viewModel = self.viewModel,
              let footer = viewModel.footer(forSection:section) else {
            return nil
        }

        return footer.view
    }

    // MARK: Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let viewModel = self.viewModel,
              let row = viewModel.row(forIndexPath: indexPath) else {
            return UITableViewCell()
        }

        self.tableView.register(row.cellClass, forCellReuseIdentifier: row.cellReuseIdentifer)
    
        if let cell = tableView.dequeueReusableCell(withIdentifier: row.cellReuseIdentifer)  {
            row.willDisplay(cell: cell,
                            atIndexPath: indexPath,
                            isSelected: tableView.indexPathForSelectedRow != nil ? tableView.indexPathForSelectedRow == indexPath : false)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel,
              let tableSection = viewModel.section(forIndex: section) else {
            return 0
        }
        
        return tableSection.rowCount
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel == nil ? 0 : viewModel!.sectionCount
    }
   
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let viewModel = self.viewModel,
              let header = viewModel.header(forSection:section) else {
            return nil
        }

        return header.title
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        guard let viewModel = self.viewModel,
              let footer = viewModel.footer(forSection:section) else {
            return nil
        }

        return footer.title
    }
}


