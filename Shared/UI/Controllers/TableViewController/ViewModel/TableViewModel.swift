//
//  TableViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation

protocol TableViewModelProtocol {
    var sections:[TableViewSectionProtocol] { get }
}

extension TableViewModelProtocol {

    var sectionCount: Int {
        return self.sections.count
    }
    
    var rowCount: Int {
        
        var rowCount: Int = 0
        
        for section in self.sections {
            rowCount += section.rowCount
        }
        
        return rowCount
    }
    
    func section(forIndex index: Int) -> TableViewSectionProtocol? {
        guard index >= 0, index < self.sections.count else {
            return nil
        }
        
        return self.sections[index]
    }

    func header(forSection section: Int) -> TableViewSectionAdornmentProtocol? {
        return self.section(forIndex: section)?.header
    }

    func footer(forSection section: Int) -> TableViewSectionAdornmentProtocol? {
        return self.section(forIndex: section)?.footer
    }
    
    func row(forSection section:Int, row: Int) -> TableViewRowProtocol? {
        if let section = self.section(forIndex: section) {
            return section.row(forIndex: row)
        }
        
        return nil
    }
    
    func row(forIndexPath indexPath: IndexPath) -> TableViewRowProtocol? {
        if let section = self.section(forIndex: indexPath.section) {
            return section.row(forIndex: indexPath.item)
        }
        return nil
    }
    
    var height: CGFloat {
        var height: CGFloat = 0
        
        for section in sections {
            height += section.height
        }
        
        return height
    }
}

struct TableViewModel<DataType, ViewType> : TableViewModelProtocol
            where ViewType: SDKCollectionViewItem, ViewType: TableViewRowCell {
    
    let sections: [TableViewSectionProtocol]

    init(withData data: [DataType]) {
        let section = TableViewSection<DataType, ViewType>(withRowData: data)
        self.sections = [ section ]
    }
}

