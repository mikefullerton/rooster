//
//  ListViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


public protocol ListViewModelProtocol {
    var sections:[ListViewSectionDescriptor] { get }
}

extension ListViewModelProtocol {

    public var sectionCount: Int {
        return self.sections.count
    }
    
    public var rowCount: Int {
        
        var rowCount: Int = 0
        
        for section in self.sections {
            rowCount += section.rowCount
        }
        
        return rowCount
    }
    
    public func section(forIndex index: Int) -> ListViewSectionDescriptor? {
        guard index >= 0, index < self.sections.count else {
            return nil
        }
        
        return self.sections[index]
    }

    public func header(forSection section: Int) -> ListViewSectionAdornmentProtocol? {
        return self.section(forIndex: section)?.header
    }

    public func footer(forSection section: Int) -> ListViewSectionAdornmentProtocol? {
        return self.section(forIndex: section)?.footer
    }
    
    public func row(forSection section:Int, row: Int) -> AbstractListViewRowDescriptor? {
        if let section = self.section(forIndex: section) {
            return section.row(forIndex: row)
        }
        
        return nil
    }
    
    public func row(forIndexPath indexPath: IndexPath) -> AbstractListViewRowDescriptor? {
        if let section = self.section(forIndex: indexPath.section) {
            return section.row(forIndex: indexPath.item)
        }
        return nil
    }
    
    public var height: CGFloat {
        var height: CGFloat = 0
        
        for section in sections {
            height += section.height
        }
        
        return height
    }
}

public struct ListViewModel<ContentType, ViewType: AbstractListViewRowController> : ListViewModelProtocol {

    public let sections: [ListViewSectionDescriptor]

    public init(withContent content: [ContentType]) {
        let rows = content.map { ListViewRowDescriptor<ContentType, ViewType>(withContent: $0) }
        self.sections = [ ListViewSectionDescriptor(withRows: rows) ]
    }
}

