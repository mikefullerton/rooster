//
//  TableViewSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit


struct TableViewSection : TableViewSectionProtocol {
    let rows: [TableViewRowProtocol]
    
    let header: TableViewSectionAdornmentProtocol?
    
    let footer: TableViewSectionAdornmentProtocol?
    
    init(withRows rows:[TableViewRowProtocol],
         header: TableViewSectionAdornmentProtocol? = nil,
         footer: TableViewSectionAdornmentProtocol? = nil) {
        
        self.rows = rows
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
