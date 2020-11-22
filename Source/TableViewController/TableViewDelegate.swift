//
//  TableViewDelegate.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class TableViewDelegate : TableViewControllerAware, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = self.viewModel.row(forIndexPath: indexPath) else {
            return 0
        }
        
        return row.height
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let header = self.viewModel.header(forSection:section) else {
            return 0
        }

//        guard let height = header.height else {
//            return UITableView.automaticDimension
//        }
        
        return header.height
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let footer = self.viewModel.footer(forSection:section) else {
            return 0
        }
        
//        guard let height = footer.height else {
//            return UITableView.automaticDimension
//        }
        
        return footer.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = self.viewModel.header(forSection:section) else {
            return nil
        }

        return header.view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = self.viewModel.footer(forSection:section) else {
            return nil
        }

        return footer.view
    }
}
