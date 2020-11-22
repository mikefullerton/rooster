//
//  TableViewDataSource.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class TableViewDataSource : TableViewControllerAware, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = self.viewModel[section] else {
            return 0
        }
        
        return tableSection.rowCount
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionCount
    }
   
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let header = self.viewModel.header(forSection:section) else {
            return nil
        }

        return header.title
    }
    
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        guard let footer = self.viewModel.footer(forSection:section) else {
//            return nil
//        }
//
//        return footer.title
//    }
}
