//
//  TableViewSectionProtocol.swift
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
}

extension TableViewSectionProtocol {
    subscript(index: Int) -> TableViewRowProtocol? {
        get {
            return self.row(forIndex: index)
        }
    }
    
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

}
