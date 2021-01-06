//
//  TableViewSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

protocol TableViewSectionProtocol {
   
    var rows: [TableViewRowProtocol] { get }
    
    var header: TableViewSectionAdornmentProtocol? { get }
    
    var footer: TableViewSectionAdornmentProtocol? { get }
    
    var height: CGFloat { get }
}

extension TableViewSectionProtocol {
    
    func row(forIndex index: Int) -> TableViewRowProtocol? {
        guard index >= 0 && index < self.rows.count else {
            return nil
        }
            
        return self.rows[index]
    }
    
    var rowCount: Int {
        return self.rows.count
    }
    
    var header: TableViewSectionAdornmentProtocol? {
        return nil
    }
    
    var footer: TableViewSectionAdornmentProtocol? {
        return nil
    }
    
    var height: CGFloat {
        
        var height: CGFloat = 0
        
        if let header = self.header {
            height += header.height
        }
        
        if let footer = self.footer {
            height += footer.height
        }
        
        for row in self.rows {
            height += row.height
        }
        
        return height
    }
    
}

struct TableViewSection<DataType, ViewType> : TableViewSectionProtocol
            where ViewType: UITableViewCell, ViewType: TableViewRowCell {
    
    let rows: [TableViewRowProtocol]
    
    let header: TableViewSectionAdornmentProtocol?
    
    let footer: TableViewSectionAdornmentProtocol?
    
    init(withRowData rows:[DataType],
         header: TableViewSectionAdornmentProtocol? = nil,
         footer: TableViewSectionAdornmentProtocol? = nil) {
        
        self.rows = rows.map { TableViewRow<DataType, ViewType>(withData: $0) }
        self.header = header
        self.footer = footer
    }
    
    var rowCount: Int {
        return self.rows.count
    }

    func row(forIndex index: Int) -> TableViewRowProtocol? {
        guard index >= 0 && index < self.rows.count else {
            return nil
        }
            
        return self.rows[index]
    }
}
