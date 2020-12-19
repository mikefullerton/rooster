//
//  TableViewModelProtocol.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

protocol TableViewModelProtocol {
    var sections:[TableViewSectionProtocol] { get }
}

extension TableViewModelProtocol {

    var sectionCount: Int {
        return self.sections.count
    }
    
    func section(forIndex index: Int) -> TableViewSectionProtocol? {
        guard index >= 0, index < self.sections.count else {
            return nil
        }
        
        return self.sections[index]
    }

    func footer(forSection section: Int) -> TableViewSectionAdornmentProtocol? {
        return self[section]?.footer
    }
    
    func header(forSection section: Int) -> TableViewSectionAdornmentProtocol? {
        return self[section]?.header
    }
    
    func row(forSection section:Int, row: Int) -> TableViewRowProtocol? {
        if let section = self[section] {
           return section[row]
        }
        
        return nil
    }
    
    func row(forIndexPath indexPath: IndexPath) -> TableViewRowProtocol? {
        if let section = self[indexPath.section] {
            return section[indexPath.item]
        }
        
        return nil
    }

    subscript(index: Int) -> TableViewSectionProtocol? {
        get {
            return self.section(forIndex: index)
        }
    }
}
