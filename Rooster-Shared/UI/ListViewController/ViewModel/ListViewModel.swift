//
//  ListViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import RoosterCore

protocol ListViewModelProtocol {
    var sections:[ListViewSectionDescriptor] { get }
}

extension ListViewModelProtocol {

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
    
    func section(forIndex index: Int) -> ListViewSectionDescriptor? {
        guard index >= 0, index < self.sections.count else {
            return nil
        }
        
        return self.sections[index]
    }

    func header(forSection section: Int) -> ListViewSectionAdornmentProtocol? {
        return self.section(forIndex: section)?.header
    }

    func footer(forSection section: Int) -> ListViewSectionAdornmentProtocol? {
        return self.section(forIndex: section)?.footer
    }
    
    func row(forSection section:Int, row: Int) -> AbstractListViewRowDescriptor? {
        if let section = self.section(forIndex: section) {
            return section.row(forIndex: row)
        }
        
        return nil
    }
    
    func row(forIndexPath indexPath: IndexPath) -> AbstractListViewRowDescriptor? {
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

struct ListViewModel<ContentType, ViewType: AbstractListViewRowController> : ListViewModelProtocol {

    let sections: [ListViewSectionDescriptor]

    init(withContent content: [ContentType]) {
        let rows = content.map { ListViewRowDescriptor<ContentType, ViewType>(withContent: $0) }
        self.sections = [ ListViewSectionDescriptor(withRows: rows) ]
    }
}

